//// LocationMapView.swift
//// 主地图视图界面
//
//import SwiftUI
//import MapKit
//
//struct LocationMapView: View {
//    @StateObject private var viewModel = LocationViewModel()
//    @State private var showDetails = false
//    
//    var body: some View {
//        ZStack {
//            // 地图视图
//            MapViewRepresentable(
//                region: $viewModel.mapRegion,
//                annotations: viewModel.currentLocation.map { [$0.toAnnotation()] } ?? []
//            )
//            .ignoresSafeArea()
//            
//            // 覆盖层 - 根据状态显示不同内容
//            VStack {
//                // 顶部状态栏
//                locationStatusBar
//                
//                Spacer()
//                
//                // 底部控制面板
//                bottomControls
//            }
//        }
//        .sheet(isPresented: $showDetails) {
//            locationDetailView
//        }
//        .alert(isPresented: Binding<Bool>(
//            get: { viewModel.errorMessage != nil },
//            set: { if !$0 { viewModel.errorMessage = nil } }
//        )) {
//            Alert(
//                title: Text("位置错误"),
//                message: Text(viewModel.errorMessage ?? "未知错误"),
//                dismissButton: .default(Text("确定"))
//            )
//        }
//        .onAppear {
//            // 视图出现时请求位置
//            viewModel.requestLocation()
//        }
//        .onDisappear {
//            // 视图消失时停止更新位置
//            viewModel.stopUpdatingLocation()
//        }
//    }
//    
//    // MARK: - 子视图
//    
//    // 位置状态栏
//    private var locationStatusBar: some View {
//        HStack {
//            // 位置状态指示器
//            HStack {
//                Image(systemName: "location.fill")
//                    .foregroundColor(viewModel.currentLocation != nil ? .blue : .gray)
//                
//                Text(locationStatusText)
//                    .font(.footnote)
//                    .foregroundColor(.primary)
//            }
//            .padding(8)
//            .background(Color.white)
//            .cornerRadius(16)
//            .shadow(radius: 2)
//            .padding(.top, 8)
//            .padding(.leading)
//            
//            Spacer()
//            
//            // 刷新按钮
//            Button(action: viewModel.requestLocation) {
//                Image(systemName: "arrow.clockwise")
//                    .padding(8)
//                    .background(Color.white)
//                    .clipShape(Circle())
//                    .shadow(radius: 2)
//            }
//            .disabled(viewModel.isLoading)
//            .padding(.top, 8)
//            .padding(.trailing)
//        }
//    }
//    
//    // 底部控制面板
//    private var bottomControls: some View {
//        VStack(spacing: 0) {
//            // 当有位置时显示详细信息卡片
//            if let location = viewModel.currentLocation {
//                VStack(alignment: .leading, spacing: 4) {
//                    Text(location.name)
//                        .font(.headline)
//                    
//                    if let address = location.address {
//                        Text(address)
//                            .font(.footnote)
//                            .foregroundColor(.secondary)
//                            .lineLimit(1)
//                    }
//                    
//                    Button("查看详情") {
//                        showDetails = true
//                    }
//                    .font(.footnote)
//                    .padding(.top, 4)
//                }
//                .padding()
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .background(Color.white)
//                .cornerRadius(12)
//                .shadow(radius: 2)
//                .padding([.horizontal, .bottom])
//            } else if viewModel.isLoading {
//                // 正在加载
//                HStack {
//                    ProgressView()
//                        .progressViewStyle(CircularProgressViewStyle())
//                    
//                    Text("获取位置中...")
//                        .font(.footnote)
//                        .padding(.leading, 4)
//                }
//                .padding()
//                .frame(maxWidth: .infinity)
//                .background(Color.white)
//                .cornerRadius(12)
//                .shadow(radius: 2)
//                .padding([.horizontal, .bottom])
//            } else if !viewModel.isAuthorized {
//                // 需要授权
//                VStack(spacing: 8) {
//                    Text("需要位置权限")
//                        .font(.headline)
//                    
//                    Text("请授权应用访问您的位置以在地图上显示")
//                        .font(.footnote)
//                        .multilineTextAlignment(.center)
//                    
//                    Button("授权位置访问") {
//                        viewModel.requestLocation()
//                    }
//                    .padding(.horizontal, 16)
//                    .padding(.vertical, 8)
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//                    .padding(.top, 4)
//                }
//                .padding()
//                .frame(maxWidth: .infinity)
//                .background(Color.white)
//                .cornerRadius(12)
//                .shadow(radius: 2)
//                .padding([.horizontal, .bottom])
//            }
//            
//            // 底部控制栏
//            HStack {
//                Spacer()
//                // 定位按钮
//                Button(action: viewModel.requestLocation) {
//                    Image(systemName: "location.fill")
//                        .padding(12)
//                        .background(Color.white)
//                        .clipShape(Circle())
//                        .shadow(radius: 2)
//                    
//                }
//                
////                Spacer()
//                
////                // 切换跟踪模式
////                Button(action: {
////                    if viewModel.currentLocation != nil {
////                        viewModel.stopUpdatingLocation()
////                        viewModel.startUpdatingLocation()
////                    } else {
////                        viewModel.startUpdatingLocation()
////                    }
////                }) {
////                    Image(systemName: "location.circle.fill")
////                        .font(.system(size: 44))
////                        .foregroundColor(.blue)
////                        .padding(4)
////                        .background(Color.white)
////                        .clipShape(Circle())
////                        .shadow(radius: 4)
////                }
//            }
//            .padding(.horizontal)
//            .padding(.bottom, 16)
//        }
//    }
//    
//    // 位置详情视图
//    private var locationDetailView: some View {
//        NavigationView {
//            VStack(alignment: .leading, spacing: 16) {
//                if let location = viewModel.currentLocation {
//                    // 位置名称
//                    HStack {
//                        Image(systemName: "mappin.circle.fill")
//                            .font(.title)
//                            .foregroundColor(.red)
//                        
//                        Text(location.name)
//                            .font(.title2)
//                            .fontWeight(.bold)
//                    }
//                    
//                    Divider()
//                    
//                    // 坐标信息
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("坐标信息")
//                            .font(.headline)
//                        
//                        HStack {
//                            Text("经度：")
//                                .foregroundColor(.secondary)
//                            Text(String(format: "%.6f", location.coordinate.longitude))
//                                .fontWeight(.medium)
//                        }
//                        
//                        HStack {
//                            Text("纬度：")
//                                .foregroundColor(.secondary)
//                            Text(String(format: "%.6f", location.coordinate.latitude))
//                                .fontWeight(.medium)
//                        }
//                    }
//                    // 显示一条线分割左右
//                    Divider()
//                    
//                    // 地址信息
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("地址信息")
//                            .font(.headline)
//                        
//                        if let address = location.address {
//                            Text(address)
//                                .fontWeight(.medium)
//                        } else {
//                            Text("地址信息不可用")
//                                .foregroundColor(.secondary)
//                                .italic()
//                        }
//                    }
//                    
//                    Spacer()
//                }
//                else {
//                    Text("位置信息不可用")
//                        .font(.headline)
//                        .foregroundColor(.secondary)
//                }
//            }
//            .padding()
//            .navigationTitle("位置详情")
//            // 使用条件编译只在iOS上设置标题显示模式
//            #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
//            .navigationBarTitleDisplayMode(.inline)
//            #endif
//        }
//    }
//    
//    // MARK: - 辅助计算属性
//    
//    // 状态文本
//    private var locationStatusText: String {
//        if viewModel.isLoading {
//            return "获取位置中..."
//        } else if let location = viewModel.currentLocation {
//            return location.address ?? "位置已获取"
//        } else if !viewModel.isAuthorized {
//            return "需要位置权限"
//        } else {
//            return "未知位置"
//        }
//    }
//}
//
//#if DEBUG
//struct LocationMapView_Previews: PreviewProvider {
//    static var previews: some View {
//        LocationMapView()
//    }
//}
//#endif




//
//
// LocationMapView.swift (修改版)
// 主地图视图界面 - 整合搜索栏、底部菜单和侧边栏

import SwiftUI
import MapKit

struct LocationMapView: View {
    // 视图模型
    @StateObject private var viewModel = LocationViewModel()
    @StateObject private var searchViewModel = SearchViewModel()
    @StateObject private var sidebarViewModel = SidebarViewModel()
    
    // 状态管理
    @State private var showDetails = false
    @State private var isSearching = false
    @State private var selectedMenuItem: MenuItemType = .home
    
    var body: some View {
        ZStack {
            // 地图视图
            MapViewRepresentable(
                region: $viewModel.mapRegion,
                annotations: viewModel.currentLocation.map { [$0.toAnnotation()] } ?? []
            )
            .ignoresSafeArea()
            
            // 覆盖层 - 根据状态显示不同内容
            VStack {
                // 顶部搜索栏
                SearchBarView(viewModel: searchViewModel, isSearching: $isSearching)
                    .padding(.top, 8)
                
                // 中间内容区域
                if isSearching {
                    // 搜索模式下的空白区域 (用于点击后关闭搜索)
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                isSearching = false
                            }
                            searchViewModel.clearResults()
                        }
                } else {
                    // 普通模式下显示状态栏和控制面板
                    locationStatusBar
                    
                    Spacer()
                    
                    // 底部控制面板
                    if selectedMenuItem == .home {
                        bottomControls
                    }
                }
            }
            
            // 右侧侧边栏
            SidebarView(viewModel: sidebarViewModel)
                .opacity(selectedMenuItem == .settings ? 1 : 0)
                .animation(.easeInOut, value: selectedMenuItem)
            
            // 底部菜单栏
            VStack {
                Spacer()
                
                // 使用菜单栏容器处理底部安全区域
                MenuBarContainer {
                    MenuBarView(
                        menuItems: createMenuItems(),
                        selectedItem: $selectedMenuItem
                    )
                }
            }
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
        .onDisappear {
            // 视图消失时停止更新位置
            viewModel.stopUpdatingLocation()
        }
//        .onChange(of: selectedMenuItem) { newValue in
//            // 当选择菜单项改变时，更新侧边栏状态
//            if newValue == .settings {
//                if !sidebarViewModel.isExpanded {
//                    sidebarViewModel.toggleSidebar()
//                }
//            } else {
//                if sidebarViewModel.isExpanded {
//                    sidebarViewModel.closeSidebar()
//                }
//            }
//            
//            // 当点击搜索时，激活搜索状态
//            if newValue == .history {
//                withAnimation {
//                    isSearching = true
//                }
//                // 显示搜索历史
//                searchViewModel.showSearchHistory()
//            }
//        }
        
        
        
        // iOS 17兼容的修复代码:
        #if swift(>=5.9) && canImport(SwiftUI) && os(iOS) && compiler(>=5.9)
        // 在 iOS 17 及以上使用新 API
        .onChange(of: selectedMenuItem) { oldValue, newValue in
            // 当选择菜单项改变时，更新侧边栏状态
            if newValue == .settings {
                if !sidebarViewModel.isExpanded {
                    sidebarViewModel.toggleSidebar()
                }
            } else {
                if sidebarViewModel.isExpanded {
                    sidebarViewModel.closeSidebar()
                }
            }
            
            // 当点击搜索时，激活搜索状态
            if newValue == .history {
                withAnimation {
                    isSearching = true
                }
                // 显示搜索历史
                searchViewModel.showSearchHistory()
            }
        }
        #else
        // 在旧版本 iOS 中使用旧 API
        .onChange(of: selectedMenuItem) { newValue in
            // 当选择菜单项改变时，更新侧边栏状态
            if newValue == .settings {
                if !sidebarViewModel.isExpanded {
                    sidebarViewModel.toggleSidebar()
                }
            } else {
                if sidebarViewModel.isExpanded {
                    sidebarViewModel.closeSidebar()
                }
            }
            
            // 当点击搜索时，激活搜索状态
            if newValue == .history {
                withAnimation {
                    isSearching = true
                }
                // 显示搜索历史
                searchViewModel.showSearchHistory()
            }
        }
        #endif
    }
    
    // MARK: - 子视图
    
    // 位置状态栏
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
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
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
            
            // 底部控制栏
            HStack {
                // 定位按钮
                Button(action: viewModel.requestLocation) {
                    Image(systemName: "location.fill")
                        .padding(12)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
                
                Spacer()
                
                // 切换跟踪模式
                Button(action: {
                    if viewModel.currentLocation != nil {
                        viewModel.stopUpdatingLocation()
                        viewModel.startUpdatingLocation()
                    } else {
                        viewModel.startUpdatingLocation()
                    }
                }) {
                    Image(systemName: "location.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.blue)
                        .padding(4)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
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
    
    // MARK: - 辅助方法
    
    // 创建菜单项
    private func createMenuItems() -> [MenuItem] {
        var items = MenuItem.defaultItems
        
        // 添加自定义操作
        for i in 0..<items.count {
            switch items[i].type {
            case .home:
                items[i].action = {
                    // 显示主页面板
                }
            case .nearby:
                items[i].action = {
                    // 搜索附近
                    viewModel.requestLocation()
                }
            case .favorite:
                items[i].action = {
                    // 显示收藏
                }
            case .history:
                items[i].action = {
                    // 显示搜索历史
                }
            case .settings:
                items[i].action = {
                    // 打开设置面板
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
        LocationMapView()
    }
}
#endif
