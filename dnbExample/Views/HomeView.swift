// 主地图视图界面 - 整合搜索栏、底部菜单和侧边栏
import SwiftUI
import MapKit
import OSLog

struct HomeView: View {
    
    // 视图模型
    @StateObject private var viewModel = LocationViewModel()
    @StateObject private var searchViewModel = SearchViewModel()
    @StateObject private var sidebarViewModel = SidebarViewModel()
    @StateObject private var houseListViewModel = HouseListViewModel()
    // 消息弹窗
    @State private var showMessageAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    
    // 状态管理
    @State private var showDetails = false
    @State private var isSearching = false
    @State private var selectedMenuItem: MenuItemType = .home
    @State private var showHouseList = false
    @State private var showAbout = false
    
    var body: some View {
        ZStack {
            // 地图视图
            MapViewRepresentable(
                region: $viewModel.mapRegion,
                annotations: viewModel.currentLocation.map { [$0.toAnnotation()] } ?? []
            )
            .ignoresSafeArea().onAppear(){
                infoLog("显示地图视图")
            }
          
            
            // 主要内容层
            VStack(spacing: 0) {
                // 1. 顶部搜索栏 - 始终显示在最上方
                SearchBarView(viewModel: searchViewModel, isSearching: $isSearching)
                    .padding(.top, 8)
                    .padding(.horizontal).onAppear(){
                        infoLog("显示顶部搜索栏")
                    }
                
                // 2. 状态信息栏 - 不再受isSearching影响，始终显示
                if !isSearching {
                    locationStatusBar
                        .padding(.top, 8).onAppear(){
                            infoLog("显示状态栏")
                        }
                }
                // 自定义调试日志
                CustomDebugLogView()
                    .padding(.top, 24)
//                       .padding(.horizontal)
                // 3. 中间空白区域
                Spacer()
                
                // 如果在搜索状态，添加一个透明层用于捕获点击事件关闭搜索
                if isSearching {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                isSearching = false
                            }
                            searchViewModel.clearResults()
                        }
                }
                
                // 4. 位置信息 - 在菜单栏上方
                if !isSearching && selectedMenuItem == .home {
                    bottomControls
                        .padding(.bottom, 8).onAppear(){
                            infoLog("显示位置信息")
                        }
                }
                
                // 5. 底部菜单栏
                MenuBarContainer {
                    MenuBarView(
                        menuItems: createMenuItems(),
                        selectedItem: $selectedMenuItem
                    ).onAppear(){
                        infoLog("显示底部菜单栏")
                    }
                }
            }
            
            // 右侧侧边栏
            SidebarView(isShowing: $showAbout)
                .opacity(selectedMenuItem == .about ? 1 : 0)
                .animation(.easeInOut, value: selectedMenuItem).onAppear(){
                    infoLog("显示右侧侧边栏")
                }
            
            // 房屋底部栏
            HouseListView(isShowing: $showHouseList).opacity(selectedMenuItem == .house ? 1:0).animation(.easeInOut, value: selectedMenuItem)
        
        }
        .sheet(isPresented: $showDetails) {
            locationDetailView
        }
        .alert(isPresented: Binding<Bool>(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Alert(
                title: Text("位置错误"),
                message: Text(viewModel.errorMessage ?? "未知错误"),
                dismissButton: .default(Text("确定"))
            )
        }
        .onAppear {
            // 设置搜索视图模型的回调
            searchViewModel.onLocationSelected = { [weak viewModel] location in
                viewModel?.updateSelectedLocation(location)
            }
            
            // 视图出现时请求位置
            viewModel.requestLocation()
        }
        .alert(isPresented: $showMessageAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("确定"))
            )
        }
        .onDisappear {
            // 视图消失时停止更新位置
            viewModel.stopUpdatingLocation()
        }
    }
    

    // MARK: - 子视图
    
    // 顶部位置状态栏
    private var locationStatusBar: some View {
        HStack {
            // 位置状态指示器
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(viewModel.currentLocation != nil ? .blue : .gray)
                
                Text(locationStatusText)
                    .font(.footnote)
                    .foregroundColor(.primary)
            }
            .padding(8)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 2)
            .padding(.top, 8)
            .padding(.leading)
            
            Spacer()
            
            // 刷新按钮
            Button(action: viewModel.requestLocation) {
                Image(systemName: "arrow.clockwise")
                    .padding(8)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 2)
            }
            .disabled(viewModel.isLoading)
            .padding(.top, 8)
            .padding(.trailing)
        }
    }
    
    // 底部控制面板
    private var bottomControls: some View {
        VStack(spacing: 0) {
            // 当有位置时显示详细信息卡片
            if let location = viewModel.currentLocation {
                HStack(alignment: .top, spacing: 16) {
                    // 左侧 - 位置信息
                    VStack(alignment: .leading, spacing: 4) {
                        Text(location.name)
                            .font(.headline)
                        
                        if let address = location.address {
                            Text(address)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        
                        Button("查看详情") {
                            showDetails = true
                        }
                        .font(.footnote)
                        .padding(.top, 4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
                    // 右侧 - 刷新按钮
                    Button(action: viewModel.requestLocation) {
                        Image(systemName: "location.fill")
                            .padding(12)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 2)
                .padding([.horizontal, .bottom])
                
            } else if viewModel.isLoading {
                // 正在加载
                HStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    
                    Text("获取位置中...")
                        .font(.footnote)
                        .padding(.leading, 4)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 2)
                .padding([.horizontal, .bottom])
            } else if !viewModel.isAuthorized {
                // 需要授权
                VStack(spacing: 8) {
                    Text("需要位置权限")
                        .font(.headline)
                    
                    Text("请授权应用访问您的位置以在地图上显示")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                    
                    Button("授权位置访问") {
                        viewModel.requestLocation()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.top, 4)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 2)
                .padding([.horizontal, .bottom])
            }
            
          
        }
    }
    
    // 位置详情视图
    private var locationDetailView: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                if let location = viewModel.currentLocation {
                    // 位置名称
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundColor(.red)
                        
                        Text(location.name)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    Divider()
                    
                    // 坐标信息
                    VStack(alignment: .leading, spacing: 8) {
                        Text("坐标信息")
                            .font(.headline)
                        
                        HStack {
                            Text("经度：")
                                .foregroundColor(.secondary)
                            Text(String(format: "%.6f", location.coordinate.longitude))
                                .fontWeight(.medium)
                        }
                        
                        HStack {
                            Text("纬度：")
                                .foregroundColor(.secondary)
                            Text(String(format: "%.6f", location.coordinate.latitude))
                                .fontWeight(.medium)
                        }
                    }
                    
                    Divider()
                    
                    // 地址信息
                    VStack(alignment: .leading, spacing: 8) {
                        Text("地址信息")
                            .font(.headline)
                        
                        if let address = location.address {
                            Text(address)
                                .fontWeight(.medium)
                        } else {
                            Text("地址信息不可用")
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                    
                    Spacer()
                }
                else {
                    Text("位置信息不可用")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .navigationTitle("位置详情")
            // 使用条件编译只在iOS上设置标题显示模式
            #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
    
    // MARK: - 底部导航菜单
    
    // 创建菜单项
    private func createMenuItems() -> [MenuItem] {
        var items = MenuItem.defaultItems
        
        // 添加自定义操作
        for i in 0..<items.count {
            switch items[i].type {
            case .home:
                items[i].action = {menuItem in
                    // 显示主页面板
                    infoLog("显示主页")
                }
            case .nearby:
                items[i].action = { menuItem in
                    // 搜索附近
                    infoLog("搜索附近")
                    viewModel.requestLocation()
                }
            case .house:
                items[i].action = {menuItem in
                    showHouseList.toggle()
                       infoLog("房间列表显示: \(showHouseList)")

                }
            case .about:
                items[i].action = {menuItem in
                    showAbout.toggle()
                       infoLog("关于页面显示: \(showAbout)")
                   
                }
            }
        }
        
        return items
    }
    
    // MARK: - 辅助计算属性
    
    // 状态文本
    private var locationStatusText: String {
        if viewModel.isLoading {
            return "获取位置中..."
        } else if let location = viewModel.currentLocation {
            return location.address ?? "位置已获取"
        } else if !viewModel.isAuthorized {
            return "需要位置权限"
        } else {
            return "未知位置"
        }
    }
}

// 扩展视图模型以支持从搜索结果更新位置
extension LocationViewModel {
    func updateSelectedLocation(_ location: Location) {
        self.currentLocation = location
        self.mapRegion = MapRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
}

#if DEBUG
struct LocationMapView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
#endif
