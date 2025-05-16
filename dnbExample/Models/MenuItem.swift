// 底部菜单项数据模型
import Foundation
import SwiftUI

struct MenuItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String // SF Symbols 名称
    let type: MenuItemType
    var action: ((MenuItemType) -> Void)?
}

// 菜单项类型
enum MenuItemType {
    case home      // 主页
    case nearby    // 附近
    case about     // 关于
    case house     // 住房
    
    // 菜单项激活状态颜色
    var activeColor: Color {
        switch self {
        case .home:
            return .blue
        case .nearby:
            return .orange
        case .house:
            return .cyan
        case .about:
            return .green
        }
    }
}

// 辅助扩展 - 默认菜单项
extension MenuItem {
    static let defaultItems: [MenuItem] = [
        MenuItem(title: "主页", icon: "house.fill", type: .home, action: { _ in /* 默认空操作 */ }),
        MenuItem(title: "附近", icon: "map.fill", type: .nearby, action: { _ in /* 默认空操作 */ }),
        MenuItem(title: "房间", icon: "bed.double.fill", type: .house, action: { _ in /* 默认空操作 */ }),
        MenuItem(title: "我的", icon: "person.fill", type: .about, action: { _ in /* 默认空操作 */ })
    ]
}
