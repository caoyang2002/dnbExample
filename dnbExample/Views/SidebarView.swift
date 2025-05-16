//
//  SidebarView.swift
//  dnbExample
//
//  Created by simons on 2025/5/16.
//

// SidebarView.swift
// 右侧折叠面板视图组件

import SwiftUI

struct SidebarView: View {
    @ObservedObject var viewModel: SidebarViewModel
    
    // 屏幕尺寸
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    // 侧边栏最小宽度
    private let minWidth: CGFloat = 60
    
    // 侧边栏最大宽度 (根据设备尺寸调整)
    private var maxWidth: CGFloat {
        horizontalSizeClass == .compact ? 280 : 350
    }
    
    // 计算当前宽度
    private var currentWidth: CGFloat {
        viewModel.isExpanded ? maxWidth : minWidth
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                Spacer()
                
                // 侧边栏主容器
                VStack(spacing: 0) {
                    // 侧边栏图标列表
                    VStack(spacing: 8) {
                        // 顶部菜单按钮 (折叠/展开控制)
                        Button(action: {
                            viewModel.toggleSidebar()
                        }) {
                            Image(systemName: viewModel.isExpanded ? "chevron.right" : "chevron.left")
                                .foregroundColor(.primary)
                                .padding(8)
                                .background(Color.white.opacity(0.9))
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                        }
                        .padding(.vertical, 8)
                        
                        // 图标列表
                        ForEach(viewModel.items) { item in
                            SidebarItemButton(
                                item: item,
                                isExpanded: viewModel.isExpanded,
                                isSelected: viewModel.isItemSelected(item)
                            )
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                    .frame(width: minWidth)
                    .background(Color.white.opacity(0.9))
                    .animation(nil, value: viewModel.isExpanded) // 防止图标列表随着展开/收起动画
                    
                    // 侧边栏内容面板 (根据选择的项目显示不同内容)
                    if viewModel.isExpanded, let selectedItem = viewModel.selectedItem {
                        VStack(spacing: 0) {
                            // 内容标题
                            HStack {
                                Text(selectedItem.title)
                                    .font(.headline)
                                
                                Spacer()
                                
                                // 关闭按钮
                                Button(action: {
                                    viewModel.selectedItem = nil
                                }) {
                                    Image(systemName: "xmark")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 14))
                                }
                            }
                            .padding()
                            .background(Color.white)
                            
                            Divider()
                            
                            // 内容区域 (根据选择的项目展示不同内容)
                            sidebarContent(for: selectedItem)
                                .frame(height: viewModel.contentHeight)
                        }
                        .frame(width: maxWidth - minWidth)
                        .background(Color.white)
                        .transition(.move(edge: .trailing))
                    }
                }
                .frame(width: currentWidth)
                .background(Color.white)
                .cornerRadius(16, corners: [.topLeft, .bottomLeft])
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: -2, y: 0)
                .offset(x: viewModel.isExpanded ? 0 : minWidth * 0.15) // 收起时轻微滑出屏幕
            }
            .frame(width: geometry.size.width + minWidth, height: geometry.size.height)
            .offset(x: minWidth)
        }
        .ignoresSafeArea() // 忽略安全区域以实现全屏效果
    }
    
    // 根据选择的项目类型返回相应的内容视图
    @ViewBuilder
    private func sidebarContent(for itemType: SidebarItemType) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                switch itemType {
                case .bookmark:
                    BookmarkContentView()
                case .history:
                    HistoryContentView()
                case .layer:
                    LayerContentView()
                case .route:
                    RouteContentView()
                case .share:
                    ShareContentView()
                case .settings:
                    SettingsContentView()
                }
            }
            .padding()
        }
    }
}

// 侧边栏项目按钮
struct SidebarItemButton: View {
    let item: SidebarItem
    let isExpanded: Bool
    let isSelected: Bool
    
    var body: some View {
        Button(action: {
            item.action?()
        }) {
            HStack(spacing: 12) {
                // 图标
                Image(systemName: item.iconName)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .white : item.iconColor)
                    .frame(width: 24, height: 24)
                
                // 展开时显示标题
                if isExpanded {
                    Text(item.title)
                        .font(.subheadline)
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    Spacer()
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, isExpanded ? 12 : 8)
            .background(isSelected ? item.iconColor : Color.white.opacity(0.01))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 辅助扩展 - 圆角指定角
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - 占位内容视图
// 这些视图仅作为示例，实际应用中需要根据需求实现

struct BookmarkContentView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("暂无收藏地点")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button("添加地点") {
                // 添加收藏地点的操作
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

struct HistoryContentView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("暂无历史记录")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

struct LayerContentView: View {
    @State private var standardSelected = true
    @State private var satelliteSelected = false
    @State private var hybridSelected = false
    @State private var trafficEnabled = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("地图类型")
                .font(.headline)
            
            Toggle("标准地图", isOn: $standardSelected)
            Toggle("卫星地图", isOn: $satelliteSelected)
            Toggle("混合地图", isOn: $hybridSelected)
            
            Divider()
            
            Text("地图选项")
                .font(.headline)
            
            Toggle("显示交通", isOn: $trafficEnabled)
        }
    }
}

struct RouteContentView: View {
    @State private var startPoint = ""
    @State private var endPoint = ""
    @State private var transportType = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("路线规划")
                .font(.headline)
            
            TextField("起点", text: $startPoint)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("终点", text: $endPoint)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Picker("交通方式", selection: $transportType) {
                Text("驾车").tag(0)
                Text("公交").tag(1)
                Text("步行").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Button("规划路线") {
                // 路线规划操作
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }
}

struct ShareContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("分享当前位置")
                .font(.headline)
            
            HStack(spacing: 24) {
                Button(action: {}) {
                    VStack {
                        Image(systemName: "message.fill")
                            .font(.system(size: 24))
                        Text("消息")
                            .font(.caption)
                    }
                }
                
                Button(action: {}) {
                    VStack {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 24))
                        Text("更多")
                            .font(.caption)
                    }
                }
            }
            .foregroundColor(.blue)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

struct SettingsContentView: View {
    @State private var distanceUnit = 0
    @State private var autoNightMode = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("应用设置")
                .font(.headline)
            
            Picker("距离单位", selection: $distanceUnit) {
                Text("公制 (km)").tag(0)
                Text("英制 (mi)").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Toggle("夜间模式自动切换", isOn: $autoNightMode)
            
            Divider()
            
            Text("应用版本: 1.0.0")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
}
