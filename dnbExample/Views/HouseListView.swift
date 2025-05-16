import SwiftUI



// 房屋列表视图 - 从底部弹出
struct HouseListView: View {
    // 视图模型
    @ObservedObject var viewModel: HouseListViewModel
    
    // 是否显示
    @Binding var isShowing: Bool
    
    // 记录拖拽状态
    @GestureState private var dragOffset: CGFloat = 0
    
    // 初始化方法，允许外部传入视图模型
    init(isShowing: Binding<Bool>, viewModel: HouseListViewModel? = nil) {
        self._isShowing = isShowing
        
        // 如果外部传入视图模型则使用，否则创建新的
        if let viewModel = viewModel {
            self.viewModel = viewModel
        } else {
            self.viewModel = HouseListViewModel()
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            // 计算当前应显示的高度
            let screenHeight = geometry.size.height
            let currentHeight = viewModel.panelState.height(screenHeight: screenHeight) + dragOffset
            
            ZStack {
                // 半透明背景
                if isShowing {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            // 点击背景关闭面板
                            withAnimation(.spring()) {
                                isShowing = false
                                viewModel.hidePanel()
                            }
                        }
                        .transition(.opacity)
                    
                    // 底部弹出面板
                    VStack(spacing: 0) {
                        // 顶部拖动条
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 40, height: 5)
                            .padding(.top, 10)
                            .padding(.bottom, 5)
                        
                        // 标题栏
                        HStack {
                            Text("您的房屋")
                                .font(.system(size: 18, weight: .semibold))
                            
                            Spacer()
                            
                            // 添加新房屋按钮
                            Button(action: {
                                // 添加房屋的操作
                                let newHouse = House(
                                    id: UUID().uuidString,
                                    name: "新添加的房屋",
                                    address: "新地址",
                                    roomCount: 2,
                                    icon: "house"
                                )
                                viewModel.addHouse(newHouse)
                            }) {
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14))
                                    .padding(8)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 15)
                        
                        // 搜索栏 - 仅在部分展开或完全展开时显示
                        if viewModel.panelState != .collapsed {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                    .padding(.leading, 8)
                                
                                TextField("搜索房屋", text: $viewModel.searchText)
                                    .font(.system(size: 14))
                                
                                if !viewModel.searchText.isEmpty {
                                    Button(action: {
                                        viewModel.searchText = ""
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                            .padding(.trailing, 8)
                                    }
                                }
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 15)
                        }
                        
                        // 内容区域
                        houseListContent()
                        
                        Spacer(minLength: 0)
                    }
                    .frame(width: geometry.size.width)
                    .frame(height: currentHeight > 0 ? currentHeight : 0)
                    .background(
                        // 美观的背景设计
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                            
                            // 顶部装饰
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.blue.opacity(0.05),
                                            Color.white.opacity(0.1)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                    )
                    .mask(RoundedCorners(tl: 16, tr: 16))
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: -5)
                    .offset(y: screenHeight - currentHeight)
                    .gesture(
                        // 添加拖拽手势
                        DragGesture()
                            .updating($dragOffset) { value, state, _ in
                                // 更新拖拽状态
                                if value.translation.height < 0 {
                                    // 向上拖动时，限制最大高度
                                    state = max(value.translation.height, -currentHeight + PanelState.expanded.height(screenHeight: screenHeight))
                                } else {
                                    // 向下拖动
                                    state = value.translation.height
                                }
                            }
                            .onEnded { value in
                                // 拖拽结束时处理状态更新
                                viewModel.handleDragGesture(
                                    dragAmount: value.translation.height,
                                    screenHeight: screenHeight
                                )
                                
                                // 更新绑定的显示状态
                                isShowing = viewModel.isShowing
                            }
                    )
                    .transition(.move(edge: .bottom))
                }
            }
            .animation(.spring(), value: isShowing)
            .edgesIgnoringSafeArea(.all)
        }
        .onAppear {
            // 当视图出现时，同步外部绑定与视图模型
            viewModel.isShowing = isShowing
            
            // 加载房屋数据
            if viewModel.houses.isEmpty || viewModel.isLoading {
                viewModel.loadHouses()
            }
        }
        .onChange(of: isShowing) { newValue in
            // 保持视图模型状态与绑定状态同步
            viewModel.isShowing = newValue
        }
        .onChange(of: viewModel.isShowing) { newValue in
            // 保持绑定状态与视图模型状态同步
            isShowing = newValue
        }
    }
    
    // 房屋列表内容区域
    @ViewBuilder
    private func houseListContent() -> some View {
        if viewModel.isLoading {
            // 加载中状态
            loadingView()
        } else if let error = viewModel.errorMessage {
            // 错误状态
            errorView(message: error)
        } else if viewModel.filteredHouses.isEmpty {
            // 空状态
            emptyView()
        } else {
            // 显示房屋列表
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.filteredHouses) { house in
                        HouseCell(house: house)
                    }
                    
                    // 空间填充，以便滚动
                    if viewModel.filteredHouses.count < 4 {
                        Spacer()
                            .frame(height: 200)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
    
    // 加载中视图
    private func loadingView() -> some View {
        VStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
                .padding()
            Text("加载中...")
                .font(.system(size: 14))
                .foregroundColor(.gray)
            Spacer()
        }
    }
    
    // 错误视图
    private func errorView(message: String) -> some View {
        VStack {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(.orange)
                .padding()
            Text(message)
                .font(.system(size: 16))
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding()
            Button("重试") {
                viewModel.loadHouses()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            Spacer()
        }
        .padding()
    }
    
    // 空状态视图
    private func emptyView() -> some View {
        VStack(spacing: 16) {
            Spacer()
            
            // 显示不同的空状态图标和消息
            if viewModel.searchText.isEmpty {
                // 没有房屋
                Image(systemName: "house.slash")
                    .font(.system(size: 50))
                    .foregroundColor(.gray.opacity(0.6))
                    .padding()
                
                Text("您还没有添加任何房屋")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                
                Text("点击右上角的"+"按钮添加您的第一个房屋")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            } else {
                // 搜索无结果
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 50))
                    .foregroundColor(.gray.opacity(0.6))
                    .padding()
                
                Text("没有找到相关房屋")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                
                Text("尝试使用不同的搜索词或添加新房屋")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
        .padding(.vertical, 40)
    }
}

// 单个房屋单元格
struct HouseCell: View {
    let house: House
    
    var body: some View {
        Button(action: {
            // 点击房屋的操作
            infoLog("点击了房屋: \(house.name)")
        }) {
            HStack(spacing: 16) {
                // 房屋图标
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: house.icon)
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                }
                
                // 房屋信息
                VStack(alignment: .leading, spacing: 4) {
                    Text(house.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(house.address)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                    
                    Text("\(house.roomCount) 个房间")
                        .font(.system(size: 12))
                        .foregroundColor(.gray.opacity(0.8))
                }
                
                Spacer()
                
                // 右箭头
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 圆角矩形（只设置上方圆角）
struct RoundedCorners: Shape {
    var tl: CGFloat = 0.0
    var tr: CGFloat = 0.0
    var bl: CGFloat = 0.0
    var br: CGFloat = 0.0
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [
                tl > 0 ? .topLeft : [],
                tr > 0 ? .topRight : [],
                bl > 0 ? .bottomLeft : [],
                br > 0 ? .bottomRight : []
            ].reduce(into: []) { $0.formUnion($1) },
            cornerRadii: CGSize(width: max(max(tl, tr), max(bl, br)), height: max(max(tl, tr), max(bl, br)))
        )
        return Path(path.cgPath)
    }
}

// 用于在菜单栏中显示的"房屋"按钮
struct HouseButton: View {
    // 在实际使用中，可能会从外部注入该视图模型
    @StateObject private var viewModel = HouseListViewModel()
    @State private var showHouseList = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                showHouseList.toggle()
                viewModel.togglePanel()
            }
        }) {
            HStack(spacing: 5) {
                Image(systemName: "house.fill")
                    .font(.system(size: 14))
                Text("房屋")
                    .font(.system(size: 14))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(20)
        }
        .overlay(
            HouseListView(isShowing: $showHouseList, viewModel: viewModel)
        )
    }
}

// 预览
struct HouseListView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            // 模拟主界面背景
            Color.gray.opacity(0.2)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    HouseButton()
                    
                    Spacer()
                }
                .padding(.bottom, 20)
            }
        }
    }
}
