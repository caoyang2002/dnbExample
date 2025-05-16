
// 侧边栏面板项目模型

import Foundation
import SwiftUI
import SwiftUI


// MARK: - 数据模型

// 侧边栏项目类型枚举
enum SidebarItemType: String, CaseIterable, Identifiable {
    case bookmark = "bookmark"
    case history = "history"
    case about = "about"
    
    var id: String { self.rawValue }
    
    var title: String {
        switch self {
        case .bookmark: return "收藏"
        case .history: return "历史"
        case .about: return "关于"
        }
    }
    
    var iconName: String {
        switch self {
        case .bookmark: return "bookmark.fill"
        case .history: return "clock.fill"
        case .about: return "person.circle.fill"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .bookmark: return .blue
        case .history: return .green
        case .about: return .orange
        }
    }
}

// 侧边栏项目模型
struct SidebarItem: Identifiable {
    let id = UUID()
    let type: SidebarItemType
    let title: String
    let iconName: String
    let iconColor: Color
    let action: (() -> Void)?
    
    init(type: SidebarItemType, action: (() -> Void)? = nil) {
        self.type = type
        self.title = type.title
        self.iconName = type.iconName
        self.iconColor = type.iconColor
        self.action = action
    }
}
