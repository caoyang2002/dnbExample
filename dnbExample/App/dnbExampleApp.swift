
// MapLocationApp.swift
// 应用入口点

import SwiftUI

@main
struct DnbaseApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView().onAppear(){
                print("启动程序")
            }
        }
    }
}
