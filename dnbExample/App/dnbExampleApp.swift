import SwiftUI
import OSLog

@main
struct DnbaseApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView().onAppear(){
                infoLog("启动程序")
            }
        }
    }
}
