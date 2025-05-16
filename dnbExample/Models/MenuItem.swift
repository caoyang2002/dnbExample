//
//  MenuItem.swift
//  dnbExample
//
//  Created by simons on 2025/5/16.
//

// MenuItem.swift
// 底部菜单项数据模型

import Foundation
import SwiftUI

struct MenuItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String // SF Symbols 名称
    let type: MenuItemType
    
    // 用于添加点击动作
    var action: (() -> Void)?
}

// 菜单项类型
enum MenuItemType {
    case home      // 主页
    case nearby    // 附近
    case favorite  // 收藏
    case history   // 历史
    case settings  // 设置
    
    // 菜单项激活状态颜色
    var activeColor: Color {
        switch self {
        case .home:
            return .blue
        case .nearby:
            return .orange
        case .favorite:
            return .red
        case .history:
            return .purple
        case .settings:
            return .gray
        }
    }
}

// 辅助扩展 - 默认菜单项
extension MenuItem {
    static let defaultItems: [MenuItem] = [
        MenuItem(title: "主页", icon: "house.fill", type: .home),
        MenuItem(title: "附近", icon: "location.fill", type: .nearby),
        MenuItem(title: "收藏", icon: "star.fill", type: .favorite),
        MenuItem(title: "历史", icon: "clock.fill", type: .history),
        MenuItem(title: "设置", icon: "gear", type: .settings)
    ]
}
