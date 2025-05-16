// DebugLogger.swift
// 全局调试日志工具

import Foundation
import SwiftUI

// 调试日志级别
enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
    
    var color: Color {
        switch self {
        case .debug: return .gray
        case .info: return .blue
        case .warning: return .orange
        case .error: return .red
        }
    }
}

// 调试工具类
final class DebugLogger {
    // 单例实例
    static let shared = DebugLogger()
    
    // 是否启用日志
    private var isEnabled = true
    
    // 日志历史
    private(set) var logHistory: [LogEntry] = []
    
    // 默认日志级别
    private var minimumLogLevel: LogLevel = .debug
    
    // 日志条目结构
    struct LogEntry: Identifiable {
        let id = UUID()
        let timestamp: Date
        let level: LogLevel
        let message: String
        let file: String
        let function: String
        let line: Int
        
        var formattedTime: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss.SSS"
            return formatter.string(from: timestamp)
        }
    }
    
    private init() {}
    
    // 启用或禁用日志
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
    }
    
    // 设置最小日志级别
    func setMinimumLogLevel(_ level: LogLevel) {
        minimumLogLevel = level
    }
    
    // 清除日志历史
    func clearHistory() {
        logHistory.removeAll()
    }
    
    // 打印日志
    func log(
        _ message: Any,
        level: LogLevel = .debug,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard isEnabled else { return }
        
        // 检查最小日志级别
        switch (minimumLogLevel, level) {
        case (.info, .debug):
            return
        case (.warning, .debug), (.warning, .info):
            return
        case (.error, .debug), (.error, .info), (.error, .warning):
            return
        default:
            break
        }
        
        // 提取文件名（不含路径）
        let fileName = (file as NSString).lastPathComponent
        
        // 创建日志条目
        let entry = LogEntry(
            timestamp: Date(),
            level: level,
            message: "\(message)",
            file: fileName,
            function: function,
            line: line
        )
        
        // 添加到历史
        logHistory.append(entry)
        
        // 控制台输出
        print("[\(level.rawValue)] [\(entry.formattedTime)] [\(fileName):\(line)] \(function): \(message)")
    }
    
    // 快捷方法
    func debug(_ message: Any, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, file: file, function: function, line: line)
    }
    
    func info(_ message: Any, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, file: file, function: function, line: line)
    }
    
    func warning(_ message: Any, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, file: file, function: function, line: line)
    }
    
    func error(_ message: Any, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, file: file, function: function, line: line)
    }
}

// 使用方便的全局函数
func debugLog(_ message: Any, file: String = #file, function: String = #function, line: Int = #line) {
    DebugLogger.shared.debug(message, file: file, function: function, line: line)
}

func infoLog(_ message: Any, file: String = #file, function: String = #function, line: Int = #line) {
    DebugLogger.shared.info(message, file: file, function: function, line: line)
}

func warningLog(_ message: Any, file: String = #file, function: String = #function, line: Int = #line) {
    DebugLogger.shared.warning(message, file: file, function: function, line: line)
}

func errorLog(_ message: Any, file: String = #file, function: String = #function, line: Int = #line) {
    DebugLogger.shared.error(message, file: file, function: function, line: line)
}

// 调试日志视图
struct DebugLogView: View {
    @ObservedObject private var viewModel = DebugLogViewModel()
    @State private var selectedLogLevel: LogLevel? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部控制栏
            HStack {
                Text("调试日志")
                    .font(.headline).onAppear(){infoLog("启动调试日志视图")}
                
                Spacer()
                
                // 日志级别过滤器
                Menu {
                    Button("全部", action: { selectedLogLevel = nil })
                    Button("调试", action: { selectedLogLevel = .debug })
                    Button("信息", action: { selectedLogLevel = .info })
                    Button("警告", action: { selectedLogLevel = .warning })
                    Button("错误", action: { selectedLogLevel = .error })
                } label: {
                    HStack {
                        Text(selectedLogLevel?.rawValue ?? "全部")
                        Image(systemName: "chevron.down")
                    }
                    .font(.subheadline)
                }
                
                Button(action: {
                    DebugLogger.shared.clearHistory()
                    viewModel.refreshLogs()
                }) {
                    Image(systemName: "trash")
                }
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            
            // 日志列表
            List {
                ForEach(filteredLogs) { entry in
                    VStack(alignment: .leading, spacing: 4) {
                        // 时间和级别
                        HStack {
                            Text("[\(entry.formattedTime)]")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.secondary)
                            
                            Text(entry.level.rawValue)
                                .font(.system(.caption, design: .monospaced))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(entry.level.color.opacity(0.2))
                                .foregroundColor(entry.level.color)
                                .cornerRadius(4)
                            
                            Spacer()
                            
                            // 文件和行号
                            Text("\(entry.file):\(entry.line)")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        
                        // 函数名
                        Text(entry.function)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.secondary)
                        
                        // 消息内容
                        Text(entry.message)
                            .font(.system(.body, design: .monospaced))
                            .lineLimit(nil)
                            .padding(.top, 2)
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(PlainListStyle())
        }
        .onAppear {
            viewModel.startLogRefreshTimer()
        }
        .onDisappear {
            viewModel.stopLogRefreshTimer()
        }
    }
    
    // 根据选择的日志级别过滤日志
    private var filteredLogs: [DebugLogger.LogEntry] {
        guard let level = selectedLogLevel else {
            return viewModel.logs
        }
        
        return viewModel.logs.filter { $0.level == level }
    }
}

// ViewModel 用于刷新日志
class DebugLogViewModel: ObservableObject {
    @Published var logs: [DebugLogger.LogEntry] = []
    private var timer: Timer?
    
    func startLogRefreshTimer() {
        refreshLogs()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.refreshLogs()
        }
    }
    
    func stopLogRefreshTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func refreshLogs() {
        logs = DebugLogger.shared.logHistory
    }
}

// 悬浮调试按钮
struct FloatingDebugButton: View {
    @State private var showDebugView = false
    @State private var position = CGPoint(x: UIScreen.main.bounds.width - 60, y: UIScreen.main.bounds.height - 160)
    @GestureState private var dragOffset = CGSize.zero
    
    var body: some View {
        ZStack {
            // 如果调试视图显示，则显示全屏遮罩视图
            if showDebugView {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showDebugView = false
                    }
                
                DebugLogView()
                    .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.height / 2)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 5)
            }
            
            // 悬浮按钮
            Button(action: {
                showDebugView.toggle()
            }) {
                Image(systemName: "ant")
                    .font(.system(size: 24))
                    .padding(12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .shadow(radius: 3)
            }
            .position(
                x: position.x + dragOffset.width,
                y: position.y + dragOffset.height
            )
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation
                    }
                    .onEnded { value in
                        position.x += value.translation.width
                        position.y += value.translation.height
                        
                        // 确保按钮不会超出屏幕
                        let screen = UIScreen.main.bounds
                        position.x = min(max(30, position.x), screen.width - 30)
                        position.y = min(max(50, position.y), screen.height - 50)
                    }
            )
        }
    }
}
