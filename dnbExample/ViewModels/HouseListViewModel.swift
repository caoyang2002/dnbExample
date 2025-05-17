import Foundation
import SwiftUI
import Combine
import OSLog

// MARK: - 房屋列表面板视图模型
class HouseListViewModel: ObservableObject {
    // 显示状态
    @Published var isShowing: Bool = false
    
    // 面板高度状态
    @Published var panelState: PanelState = .expanded 
    
    // 房屋数据列表
    @Published var houses: [House] = []
    
    // 搜索文本
    @Published var searchText: String = ""
    
    // 加载状态
    @Published var isLoading: Bool = false
    
    // 错误信息
    @Published var errorMessage: String? = nil
    
    // 订阅存储
    private var cancellables = Set<AnyCancellable>()
    
    // 初始化
    init(initialHouses: [House] = []) {
        if initialHouses.isEmpty {
            self.houses = House.defaultHouses
        } else {
            self.houses = initialHouses
        }
    }
    
    // 过滤后的房屋列表
    var filteredHouses: [House] {
        if searchText.isEmpty {
            return houses
        } else {
            return houses.filter { house in
                house.name.localizedCaseInsensitiveContains(searchText) ||
                house.address.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // 加载房屋数据
    func loadHouses() {
        isLoading = true
        errorMessage = nil
        
        // 模拟网络请求延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self = self else { return }
            
            // 实际应用中可能从API获取数据
            // 模拟成功获取数据
            self.houses = House.defaultHouses
            self.isLoading = false
            
            infoLog("加载了 \(self.houses.count) 个房屋")
        }
    }
    
    // 添加新房屋
    func addHouse(_ house: House) {
        houses.append(house)
        infoLog("添加了新房屋: \(house.name)")
    }
    
    // 删除房屋
    func deleteHouse(at indexSet: IndexSet) {
        houses.remove(atOffsets: indexSet)
        infoLog("删除了房屋")
    }
    
    // 切换面板显示状态
    func togglePanel() {
        withAnimation(.spring()) {
            isShowing.toggle()
            infoLog("切换面板显示状态: \(isShowing)")
            
            // 关闭时重置状态
            if !isShowing {
                resetPanel()
            }
        }
    }
    
    // 显示面板
    func showPanel() {
        withAnimation(.spring()) {
            isShowing = true
            panelState = .halfExpanded
            infoLog("显示面板")
        }
    }
    
    // 隐藏面板
    func hidePanel() {
        withAnimation(.spring()) {
            isShowing = false
            resetPanel()
            infoLog("隐藏面板")
        }
    }
    
    // 重置面板状态
    private func resetPanel() {
        searchText = ""
        panelState = .collapsed
        infoLog("重置面板状态")
    }
    
    func resetPanelState() {
        searchText = ""
        panelState = .halfExpanded
        infoLog("重置面板状态")
    }
    // 更新面板状态
    func updatePanelState(_ newState: PanelState) {
        withAnimation(.spring()) {
            panelState = newState
            infoLog("更新面板状态: \(newState)")
        }
    }
    
    // 根据拖拽动作更新面板状态
    func handleDragGesture(dragAmount: CGFloat, screenHeight: CGFloat) {
        let dragThreshold: CGFloat = 40
        
        // 向上拖动
        if dragAmount > dragThreshold {
            // 向下拖动
            infoLog("向下拖动")
            switch panelState {
            case .expanded:
                panelState = .halfExpanded
            case .halfExpanded:
                isShowing = false
                hidePanel()
            case .collapsed:
                isShowing = false
                hidePanel()
            }
        } else if dragAmount < -dragThreshold {
            // 向上拖动
            infoLog("向上拖动")
            switch panelState {
            case .halfExpanded:
                panelState = .expanded
            case .collapsed:
                panelState = .halfExpanded
            default:
                break
            }
        }
    }
}


