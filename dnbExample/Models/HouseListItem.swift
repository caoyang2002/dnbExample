
import Foundation
import SwiftUI
import OSLog
// MARK: - 模型定义和扩展

// 面板高度状态
enum PanelState: String {
    case collapsed   // 折叠状态
    case partial     // 部分展开
    case expanded    // 完全展开
    
    // 获取对应状态的高度
    func height(screenHeight: CGFloat) -> CGFloat {
        switch self {
        case .collapsed:
            return 100
        case .partial:
            return screenHeight * 0.4
        case .expanded:
            return screenHeight * 0.8
        }
    }
}

// 房屋模型
struct House: Identifiable, Equatable {
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

// 日志函数
//func infoLog(_ message: String) {
//    if #available(iOS 14.0, *) {
//        let logger = Logger(subsystem: "com.yourapp.houselist", category: "HouseList")
//        logger.info("\(message)")
//    } else {
//        NSLog("[HouseList] \(message)")
//    }
//}
