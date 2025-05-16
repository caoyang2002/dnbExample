//
//  SidebarItem.swift
//  dnbExample
//
//  Created by simons on 2025/5/16.
//

// SidebarItem.swift
// 侧边栏面板项目模型

import Foundation
import SwiftUI

// 侧边栏项目类型
enum SidebarItemType {
    case bookmark   // 书签/收藏
    case history    // 历史记录
    case layer      // 地图图层
    case route      // 路线
    case share      // 分享
    case settings   // 设置
    
    // 图标名称 (SF Symbols)
    var iconName: String {
        switch self {
        case .bookmark:
            return "bookmark.fill"
        case .history:
            return "clock.fill"
        case .layer:
            return "square.3.stack.3d.top.fill"
        case .route:
            return "map.fill"
        case .share:
            return "square.and.arrow.up.fill"
        case .settings:
            return "gear"
        }
    }
    
    // 项目标题
    var title: String {
        switch self {
        case .bookmark:
            return "收藏地点"
        case .history:
            return "历史记录"
        case .layer:
            return "地图图层"
        case .route:
            return "路线规划"
        case .share:
            return "分享"
        case .settings:
            return "设置"
        }
    }
    
    // 图标颜色
    var iconColor: Color {
        switch self {
        case .bookmark:
            return .red
        case .history:
            return .purple
        case .layer:
            return .orange
        case .route:
            return .blue
        case .share:
            return .green
        case .settings:
            return .gray
        }
    }
}

// 侧边栏项目模型
struct SidebarItem: Identifiable {
    let id = UUID()
    let type: SidebarItemType
    
    // 便利属性
    var iconName: String { type.iconName }
    var title: String { type.title }
    var iconColor: Color { type.iconColor }
    
    // 点击动作
    var action: (() -> Void)?
}

// 辅助扩展 - 创建默认侧边栏项目
extension SidebarItem {
    static let defaultItems: [SidebarItem] = [
        SidebarItem(type: .bookmark),
        SidebarItem(type: .history),
        SidebarItem(type: .layer),
        SidebarItem(type: .route),
        SidebarItem(type: .share),
        SidebarItem(type: .settings)
    ]
}
