import SwiftUI

// 房屋详情面板 - 作为二级弹出面板
struct HouseDetailPanelView: View {
    // 是否显示
    @Binding var isShowing: Bool
    
    // 要显示的房屋
    let house: House
    
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
    
    // 记录拖拽状态
    @GestureState private var dragState = DragState.inactive
    
    // 当前面板高度（与动画分离）
    @State private var currentHeight: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            
            ZStack {
                // 半透明背景
                if isShowing {
                    Color.black.opacity(0.6) // 稍微深一点的背景，区分二级面板
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            // 点击背景关闭面板
                            withAnimation(.spring()) {
                                isShowing = false
                            }
                            infoLog("详情面板 - 背景点击关闭")
                        }
                        .transition(.opacity)
                    
                    // 详情面板主体
                    VStack(spacing: 0) {
                        // 顶部拖动条
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 40, height: 5)
                            .padding(.top, 10)
                            .padding(.bottom, 5)
                        
                        // 标题栏 - 返回按钮和标题
                        HStack {
                            Button(action: {
                                withAnimation(.spring()) {
                                    isShowing = false
                                }
                                infoLog("详情面板 - 返回按钮点击")
                            }) {
                                HStack(spacing: 5) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 16))
                                    Text("返回")
                                        .font(.system(size: 16))
                                }
                                .foregroundColor(.blue)
                            }
                            
                            Spacer()
                            
                            Text("房屋详情")
                                .font(.system(size: 18, weight: .semibold))
                            
                            Spacer()
                            
                            // 右侧空白区域，保持标题居中
                            Text("")
                                .frame(width: 50)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 15)
                        
                        // 详情内容 - 使用原有的HouseDetailView内容
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                                // 房屋标题和图标
                                HStack {
                                    Text(house.name)
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                    
                                    ZStack {
                                        Circle()
                                            .fill(Color.blue.opacity(0.1))
                                            .frame(width: 70, height: 70)
                                        
                                        Image(systemName: house.icon)
                                            .font(.system(size: 30))
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding(.bottom, 10)
                                
                                // 地址信息
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("地址")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    
                                    Text(house.address)
                                        .font(.body)
                                }
                                .padding(.bottom, 10)
                                
                                // 房间信息
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("房间数量")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    
                                    Text("\(house.roomCount) 个房间")
                                        .font(.body)
                                }
                                
                                // 这里可以添加更多房屋详情内容
                                
                                Spacer()
                            }
                            .padding()
                        }
                        
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
                        // 拖拽手势
                        DragGesture()
                            .updating($dragState) { value, state, _ in
                                state = .dragging(translation: value.translation.height)
                            }
                            .onEnded { value in
                                // 向下拖动关闭面板
                                if value.translation.height > 50 {
                                    withAnimation(.spring()) {
                                        isShowing = false
                                    }
                                    infoLog("详情面板 - 拖动关闭")
                                } else {
                                    // 恢复原始位置
                                    withAnimation(.spring()) {
                                        updateHeight(screenHeight: screenHeight)
                                    }
                                }
                            }
                    )
                    .transition(.move(edge: .bottom))
                    .onAppear {
                        // 设置面板高度 - 详情面板始终全屏显示
                        withAnimation(.spring()) {
                            currentHeight = screenHeight * 0.9 // 90%的屏幕高度
                        }
                        infoLog("详情面板显示 - \(house.name)")
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    // 更新面板高度
    private func updateHeight(screenHeight: CGFloat) {
        currentHeight = screenHeight * 0.9 // 保持90%高度
    }
}
