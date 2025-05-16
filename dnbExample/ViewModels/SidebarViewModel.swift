//
//  SidebarViewModel.swift
//  dnbExample
//
//  Created by simons on 2025/5/16.
//

// SidebarViewModel.swift
// 侧边栏面板视图模型

import Foundation
import SwiftUI
import Combine

class SidebarViewModel: ObservableObject {
    // 侧边栏展开状态
    @Published var isExpanded: Bool = false
    
    // 侧边栏项目
    @Published var items: [SidebarItem]
    
    // 当前选中项
    @Published var selectedItem: SidebarItemType?
    
    // 侧边栏面板内容高度
    @Published var contentHeight: CGFloat = 0
    
    // 订阅存储
    private var cancellables = Set<AnyCancellable>()
    
    init(items: [SidebarItem] = SidebarItem.defaultItems) {
        self.items = items
        
        // 为每个项目添加默认动作
        setupItemActions()
    }
    
    // 设置项目动作
    private func setupItemActions() {
        for i in 0..<items.count {
            items[i].action = { [weak self] in
                guard let self = self else { return }
                
                let itemType = self.items[i].type
                if self.selectedItem == itemType {
                    // 如果已选中，则取消选中
                    self.selectedItem = nil
                } else {
                    // 否则选中该项
                    self.selectedItem = itemType
                }
                
                // 根据不同项目类型执行特定操作
                self.handleItemAction(type: itemType)
            }
        }
    }
    
    // 处理项目点击动作
    private func handleItemAction(type: SidebarItemType) {
        switch type {
        case .bookmark:
            // 显示收藏地点列表
            contentHeight = 300
        case .history:
            // 显示历史记录
            contentHeight = 300
        case .layer:
            // 显示地图图层选项
            contentHeight = 200
        case .route:
            // 显示路线规划选项
            contentHeight = 350
        case .share:
            // 显示分享选项
            contentHeight = 150
        case .settings:
            // 显示设置选项
            contentHeight = 250
        }
    }
    
    // 切换侧边栏展开状态
    func toggleSidebar() {
        withAnimation(.spring()) {
            isExpanded.toggle()
            
            // 关闭时重置选中状态
            if !isExpanded {
                selectedItem = nil
            }
        }
    }
    
    // 关闭侧边栏
    func closeSidebar() {
        withAnimation(.spring()) {
            isExpanded = false
            selectedItem = nil
        }
    }
    
    // 检查项目是否被选中
    func isItemSelected(_ item: SidebarItem) -> Bool {
        return selectedItem == item.type
    }
}
