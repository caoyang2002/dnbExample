
import Foundation
import SwiftUI
import OSLog
// MARK: - 模型定义和扩展

// 面板高度状态
enum PanelState {
    case collapsed    // 折叠状态（屏幕20%）
    case halfExpanded // 半展开状态（屏幕50%）
    case expanded     // 完全展开状态（屏幕90%）
    
    // 根据屏幕高度计算面板高度
    func height(screenHeight: CGFloat) -> CGFloat {
        switch self {
        case .collapsed:
            return screenHeight * 0
        case .halfExpanded:
            return screenHeight * 0.75
        case .expanded:
            return screenHeight * 0.95
        }
    }
}
// 房屋模型
struct House: Identifiable, Equatable,Hashable {
    let id: String
    let name: String
    let address: String
    let roomCount: Int
    let icon: String
    
    // 默认房屋数据
    static var defaultHouses: [House] = [
        House(id: "1", name: "翡翠湾花园", address: "北京市朝阳区建国路18号", roomCount: 5, icon: "house.fill"),
        House(id: "2", name: "阳光小区", address: "上海市浦东新区陆家嘴环路1088号", roomCount: 4, icon: "building.2.fill"),
        House(id: "3", name: "御景园", address: "广州市天河区天河路385号", roomCount: 3, icon: "house.lodge.fill"),
        House(id: "4", name: "蓝湾半岛", address: "深圳市南山区后海大道2888号", roomCount: 6, icon: "building.fill"),
        House(id: "5", name: "星河湾", address: "杭州市西湖区西溪路128号", roomCount: 4, icon: "house.and.flag.fill"),
        House(id: "6", name: "紫金华府", address: "南京市鼓楼区中央路201号", roomCount: 3, icon: "house.circle.fill")
    ]
}

