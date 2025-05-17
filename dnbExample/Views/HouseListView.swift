import Foundation
import SwiftUI
import Combine
import OSLog


struct HouseListView: View {
    // 视图模型
    @ObservedObject var viewModel: HouseListViewModel
    
    // 是否显示
    @Binding var isShowing: Bool
    
    @State private var showDetailPanel = false
    @State private var selectedHouseForDetail: House? = nil
    
    // 拖拽状态
    enum DragState {
        case inactive
        case dragging(translation: CGFloat)
        
        var translation: CGFloat {
            switch self {
            case .inactive:
                return 0
            case .dragging(let translation):
                return translation
            }
        }
    }
    
    // 记录拖拽状态 - 使用更轻量的方式
    @GestureState private var dragState = DragState.inactive
    
    // 当前面板高度（与动画分离）
    @State private var currentHeight: CGFloat = 0
    
    // 选中的房屋（用于导航）
    @State private var selectedHouse: House? = nil
    @State private var showHouseDetail = false
    
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
            
            ZStack {
                // 半透明背景 - 修改了条件判断和动画
                if isShowing {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            // 点击背景关闭面板 - 直接设置绑定状态
                            isShowing = false
                            viewModel.isShowing = false
                            viewModel.resetPanelState()
                            infoLog("背景点击 - 关闭面板")
                        }
                        .transition(.opacity)
                        .onAppear() {
                            infoLog("显示半透明背景")
                        }
                        .onDisappear {
                            infoLog("隐藏半透明背景")
                        }
                    
                    // 底部弹出面板
                    VStack(spacing: 0) {
                        // 顶部拖动条
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 40, height: 5)
                            .padding(.top, 10)
                            .padding(.bottom, 5)
                            .onAppear() {
                                infoLog("显示顶部拖动条")
                            }
                        
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
                    .frame(height: currentHeight)
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
                    .offset(y: max(0, screenHeight - currentHeight + dragState.translation))
                    .gesture(
                        // 优化拖拽手势实现
                        DragGesture()
                            .updating($dragState) { value, state, _ in
                                state = .dragging(translation: value.translation.height)
                            }
                            .onEnded { value in
                                // 拖拽结束时将处理逻辑委托给视图模型
                                handleDragGestureEnded(value: value, screenHeight: screenHeight)
                            }
                    )
                    .transition(.move(edge: .bottom))
                }
            }
            // onChange修改为兼容新旧版本iOS - 更新为使用本地方法
            .modifier(PanelStateChangeModifier(panelState: viewModel.panelState) {
                withAnimation(.spring()) {
                    updateHeight(screenHeight: screenHeight)
                }
            })
            .onAppear {
                // 当视图出现时，设置为全屏显示
                if isShowing && currentHeight == 0 {
                    viewModel.panelState = .expanded
                    updateHeight(screenHeight: screenHeight)
                    infoLog("视图出现，设置为全屏显示")
                }
                
                // 同步状态
                viewModel.isShowing = isShowing
                
                // 加载房屋数据
                if viewModel.houses.isEmpty || viewModel.isLoading {
                    viewModel.loadHouses()
                }
            }
            // onChange修改为兼容新旧版本iOS - 更新同步逻辑
            .modifier(ShowingChangeModifier(isShowing: isShowing) { newValue in
                // 保持视图模型状态与绑定状态同步
                if viewModel.isShowing != newValue {
                    viewModel.isShowing = newValue
                    infoLog("绑定isShowing改变: \(newValue)，同步到视图模型")
                    
                    // 当打开面板时设置为半屏
                    if newValue {
                        viewModel.panelState = .halfExpanded
                        withAnimation(.spring()) {
                            updateHeight(screenHeight: screenHeight)
                        }
                    } else {
                        withAnimation(.spring()) {
                            currentHeight = 0
                        }
                    }
                }
            })
            // 添加对视图模型isShowing的监听
            .modifier(ShowingChangeModifier(isShowing: viewModel.isShowing) { newValue in
                // 保持绑定状态与视图模型状态同步
                if isShowing != newValue {
                    isShowing = newValue
                    infoLog("视图模型isShowing改变: \(newValue)，同步到绑定")
                }
            })
        }
        .edgesIgnoringSafeArea(.all)
        if let house = selectedHouseForDetail {
            HouseDetailPanelView(isShowing: $showDetailPanel, house: house)
        }
    }
    
    // 处理拖拽手势结束
    private func handleDragGestureEnded(value: DragGesture.Value, screenHeight: CGFloat) {
        let dragThreshold: CGFloat = 40
        
        // 根据拖拽方向和距离确定面板状态
        if value.translation.height > dragThreshold {
            // 向下拖动
            infoLog("向下拖动")
            switch viewModel.panelState {
            case .expanded: // 完全展开
                withAnimation(.spring()) {
                    viewModel.panelState = .halfExpanded
                    updateHeight(screenHeight: screenHeight)
                }
            case .halfExpanded: // 一半
                withAnimation(.spring()) {
                    // 更新绑定状态，确保UI正确响应
                    isShowing = false
                    viewModel.isShowing = false
                    currentHeight = 0
                }
                infoLog("向下拖动关闭面板")
            case .collapsed: // 折叠
                withAnimation(.spring()) {
                    // 更新绑定状态，确保UI正确响应
                    isShowing = false
                    viewModel.isShowing = false
                    currentHeight = 0
                }
                infoLog("向下拖动关闭面板")
            }
        } else if value.translation.height < -dragThreshold {
            // 向上拖动
            infoLog("向上拖动")
            withAnimation(.spring()) {
                switch viewModel.panelState {
                case .halfExpanded: // 一般
                    infoLog("完全展开")
                    viewModel.panelState = .expanded
                case .collapsed: // 折叠
                    infoLog("折叠")
                    viewModel.panelState = .halfExpanded
                default:
                    break
                }
                updateHeight(screenHeight: screenHeight)
            }
        } else {
            // 如果拖拽距离不够，保持当前状态但更新高度
            withAnimation(.spring()) {
                updateHeight(screenHeight: screenHeight)
            }
        }
    }
    
    // 更新面板高度 - 将计算逻辑抽离出来
    private func updateHeight(screenHeight: CGFloat) {
        currentHeight = viewModel.panelState.height(screenHeight: screenHeight)
        infoLog("更新面板高度: \(currentHeight)")
    }
    
    // MARK: - 房屋列表内容区域
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
                        // 修改点击处理
                        .onTapGesture {
                            selectedHouseForDetail = house
                            showDetailPanel = true
                            infoLog("点击了房屋: \(house.name)")
                        }
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

// 单个房屋单元格 - 移除了Button包装，由父视图处理点击事件
struct HouseCell: View {
    let house: House
    
    var body: some View {
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


// 自定义修饰符 - 兼容iOS 17的onChange
struct PanelStateChangeModifier: ViewModifier {
    let panelState: PanelState
    let action: () -> Void
    
    @State private var previousPanelState: PanelState

    
    init(panelState: PanelState, action: @escaping () -> Void) {
        self.panelState = panelState
        self.action = action
        _previousPanelState = State(initialValue: panelState)
    }
    
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content.onChange(of: panelState) { action() }
        } else {
            content.onChange(of: panelState) { _ in action() }
        }
    }
}

// 自定义修饰符 - 兼容iOS 17的onChange (布尔值版本)
struct ShowingChangeModifier: ViewModifier {
    let isShowing: Bool
    let action: (Bool) -> Void
    
    @State private var previousIsShowing: Bool
    
    init(isShowing: Bool, action: @escaping (Bool) -> Void) {
        self.isShowing = isShowing
        self.action = action
        _previousIsShowing = State(initialValue: isShowing)
    }
    
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content.onChange(of: isShowing) { _, newValue in
                action(newValue)
            }
        } else {
            content.onChange(of: isShowing) { newValue in
                action(newValue)
            }
        }
    }
}
