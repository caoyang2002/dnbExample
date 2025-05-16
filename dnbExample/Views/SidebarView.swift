import Foundation
import SwiftUI
// MARK: - 主视图

// 右侧折叠面板视图组件
struct SidebarView: View {
    @ObservedObject var viewModel: SidebarViewModel
    
    // 屏幕尺寸
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    // 是否显示
    @Binding var isShowing: Bool
    
    // 侧边栏宽度 (根据设备尺寸调整)
    private var sidebarWidth: CGFloat {
        horizontalSizeClass == .compact ? 280 : 350
    }
    
    // 初始化方法，允许外部传入视图模型
    init(isShowing: Binding<Bool>, viewModel: SidebarViewModel? = nil) {
        self._isShowing = isShowing
        
        // 如果外部传入视图模型则使用，否则创建新的
        if let viewModel = viewModel {
            self.viewModel = viewModel
        } else {
            self.viewModel = SidebarViewModel()
        }
    }
    
    // 主视图
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景遮罩，点击时关闭侧边栏
                if isShowing {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring()) {
                                isShowing = false
                            }
                        }
                        .transition(.opacity)
                }
                
                HStack(spacing: 0) {
                    // 主要内容，将占据整个屏幕宽度减去侧边栏宽度
                    Spacer()
                    
                    // 侧边栏容器
                    if isShowing {
                        sidebarContainer()
                            .transition(.move(edge: .trailing))
                    }
                }
            }
            .onAppear {
                infoLog("显示主视图")
            }
        }
        .animation(.spring(), value: isShowing)
    }
    
    // 侧边栏容器
    @ViewBuilder
    private func sidebarContainer() -> some View {
        VStack(spacing: 0) {
            // 顶部标签栏
            tabBar()
            
            Divider()
            
            // 主要内容区域
            mainContentArea()
            
            Spacer()
        }
        .frame(width: sidebarWidth)
        .background(Color.white)
        .cornerRadius(16, corners: [.topLeft, .bottomLeft])
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: -2, y: 0)
    }
    
    // 标签栏
    @ViewBuilder
    private func tabBar() -> some View {
        HStack(spacing: 0) {
            ForEach(viewModel.items) { item in
                tabButton(for: item)
            }
            
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .background(Color.white)
        .onAppear {
            infoLog("标签栏")
        }
    }
    
    // 标签按钮
    @ViewBuilder
    private func tabButton(for item: SidebarItem) -> some View {
        // 将按钮操作拆分为变量
        let isSelected = viewModel.isItemSelected(item)
        let textColor: Color = isSelected ? .blue : .gray
        let backgroundColor: Color = isSelected ? Color.blue.opacity(0.1) : Color.clear
        
        Button(action: {
            viewModel.selectedItem = item.type
        }) {
            HStack {
                Image(systemName: item.iconName)
                    .foregroundColor(textColor)
                
                Text(item.title)
                    .foregroundColor(textColor)
                    .font(.subheadline)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(backgroundColor)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // 主要内容区域
    @ViewBuilder
    private func mainContentArea() -> some View {
        if let selectedItem = viewModel.selectedItem {
            sidebarContent(for: selectedItem)
        } else {
            // 默认展示个人信息
            PersonalInfoView()
        }
    }
    
    // 根据选择的项目类型返回相应的内容视图
    @ViewBuilder
    private func sidebarContent(for itemType: SidebarItemType) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                switch itemType {
                case .bookmark:
                    BookmarkContentView()
                case .history:
                    HistoryContentView()
                case .about:
                    PersonalInfoView()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(UIColor.systemBackground))
    }
}

// MARK: - 子视图

// 个人信息视图
private struct PersonalInfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 用户头像和名称
            HStack(spacing: 12) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("用户名")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("查看个人资料 >")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            .padding(.bottom, 8)
            
            // 各项功能
            VStack(spacing: 0) {
                PersonalInfoRow(icon: "gear", title: "设置")
                PersonalInfoRow(icon: "bell", title: "通知")
                PersonalInfoRow(icon: "shield", title: "隐私与安全")
                PersonalInfoRow(icon: "questionmark.circle", title: "帮助与反馈")
                PersonalInfoRow(icon: "info.circle", title: "关于")
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            
            Spacer()
        }
        .padding()
    }
}

// 个人信息行项目
private struct PersonalInfoRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 24, height: 24)
                    .foregroundColor(.gray)
                
                Text(title)
                    .font(.body)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color.white)
            .contentShape(Rectangle())
            .onTapGesture {
                // 处理点击
                print("点击了 \(title)")
            }
            
            if title != "关于" { // 最后一项不显示分割线
                Divider()
                    .padding(.leading, 40)
            }
        }
    }
}

// MARK: - 辅助扩展

// 圆角指定角
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

// 收藏地点
struct BookmarkContentView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 标题区域
            HStack {
                Text("您的收藏")
                    .font(.system(size: 17, weight: .semibold))
                Spacer()
                Button(action: {
                    print("管理收藏")
                }) {
                    Text("管理")
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                }
            }
            
            // 空状态展示
            VStack(spacing: 16) {
                Image(systemName: "bookmark.slash")
                    .font(.system(size: 36))
                    .foregroundColor(.gray.opacity(0.6))
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Circle())
                
                Text("暂无收藏地点")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                
                Text("您可以将常去的地点添加到收藏，方便快速访问")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 20)
                
                Button(action: {
                    // 添加收藏地点的操作
                    print("添加收藏地点")
                }) {
                    HStack {
                        Image(systemName: "plus")
                            .font(.system(size: 14))
                        Text("添加地点")
                            .font(.system(size: 15, weight: .medium))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .shadow(color: Color.blue.opacity(0.3), radius: 3, x: 0, y: 1)
                .padding(.top, 8)
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.vertical, 8)
    }
}

// 历史记录
struct HistoryContentView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 标题区域
            HStack {
                Text("搜索历史")
                    .font(.system(size: 17, weight: .semibold))
                Spacer()
                Button(action: {
                    // 清除历史
                    print("清除历史记录")
                }) {
                    Text("清除")
                        .font(.system(size: 14))
                        .foregroundColor(.red.opacity(0.8))
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // 空状态展示
            VStack(spacing: 16) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 36))
                    .foregroundColor(.gray.opacity(0.6))
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Circle())
                
                Text("暂无历史记录")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                
                Text("您的搜索历史将显示在这里，方便您快速查找之前访问过的地点")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 20)
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - 预览

#Preview("侧边栏显示") {
    @State var isShowing = true
    let viewModel = SidebarViewModel()
    viewModel.selectedItem = .about
    
    return SidebarView(isShowing: $isShowing, viewModel: viewModel)
        .frame(width: 400, height: 700)
        .background(Color.gray.opacity(0.1))
}

#Preview("收藏页面") {
    @State var isShowing = true
    let viewModel = SidebarViewModel()
    viewModel.selectedItem = .bookmark
    
    return SidebarView(isShowing: $isShowing, viewModel: viewModel)
        .frame(width: 400, height: 700)
        .background(Color.gray.opacity(0.1))
}

#Preview("历史页面") {
    @State var isShowing = true
    let viewModel = SidebarViewModel()
    viewModel.selectedItem = .history
    
    return SidebarView(isShowing: $isShowing, viewModel: viewModel)
        .frame(width: 400, height: 700)
        .background(Color.gray.opacity(0.1))
}
