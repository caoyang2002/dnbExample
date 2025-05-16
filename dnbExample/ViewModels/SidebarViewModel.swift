import Foundation
import SwiftUI

// 侧边栏视图模型
class SidebarViewModel: ObservableObject {
    @Published var selectedItem: SidebarItemType? = .about
    @Published var items: [SidebarItem] = []
    
    init() {
        setupItems()
    }
    
    private func setupItems() {
        items = SidebarItemType.allCases.map { itemType in
            SidebarItem(type: itemType) { [weak self] in
                self?.selectedItem = itemType
            }
        }
    }
    
    func isItemSelected(_ item: SidebarItem) -> Bool {
        return selectedItem == item.type
    }
}
