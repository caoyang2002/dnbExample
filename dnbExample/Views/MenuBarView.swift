//
//  MenuBarView.swift
//  dnbExample
//
//  Created by simons on 2025/5/16.
//

// MenuBarView.swift
// 底部菜单栏视图组件

import SwiftUI

struct MenuBarView: View {
    // 菜单项列表
    let menuItems: [MenuItem]
    
    // 当前选中菜单项
    @Binding var selectedItem: MenuItemType
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(menuItems) { item in
                MenuItemView(
                    item: item,
                    isSelected: selectedItem == item.type,
                    action: {
                        // 更新选中项
                        withAnimation {
                            selectedItem = item.type
                        }
                        // 执行菜单项自定义动作
                        item.action?()
                    }
                )
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 8)
        .background(
            Group {
                #if os(iOS) || targetEnvironment(macCatalyst)
                Color(UIColor.systemBackground)
                #else
                Color.white
                #endif
            }
        )
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -2)
    }
}

// 单个菜单项视图
struct MenuItemView: View {
    let item: MenuItem
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: item.icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? item.type.activeColor : .gray)
                
                Text(item.title)
                    .font(.system(size: 12))
                    .fontWeight(isSelected ? .medium : .regular)
                    .foregroundColor(isSelected ? item.type.activeColor : .gray)
            }
            .frame(height: 50)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 菜单栏容器 - 用于在主视图中添加底部安全区域填充
struct MenuBarContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            content
            
            // 为底部添加安全区域填充 (iOS/iPadOS)
            #if os(iOS) || targetEnvironment(macCatalyst)
            GeometryReader { geometry in
                Color.clear
                    .frame(height: geometry.safeAreaInsets.bottom)
                    .background(
                        Color(UIColor.systemBackground)
                            .edgesIgnoringSafeArea(.bottom)
                    )
            }
            .frame(height: 0)
            #endif
        }
    }
}
