//
//  CustomLogger.swift
//  dnbExample
//
//  Created by simons on 2025/5/16.
//
import Foundation
import SwiftUI
struct CustomDebugLogView: View {
    // 自动刷新状态
    @State private var logs: [DebugLogger.LogEntry] = []
    @State private var timer: Timer? = nil
    @State private var showFullLog = false
    @State private var filter: LogLevel? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部控制栏
            HStack {
                Text("运行日志")
                    .font(.headline)
                
                Spacer()
                
                // 过滤按钮
                Menu {
                    Button("全部", action: { filter = nil })
                    Button("调试", action: { filter = .debug })
                    Button("信息", action: { filter = .info })
                    Button("警告", action: { filter = .warning })
                    Button("错误", action: { filter = .error })
                } label: {
                    Label(filter?.rawValue ?? "全部", systemImage: "line.3.horizontal.decrease.circle")
                        .font(.footnote)
                }
                
                // 清除按钮
                Button(action: {
                    DebugLogger.shared.clearHistory()
                    refreshLogs()
                }) {
                    Image(systemName: "trash")
                        .font(.footnote)
                }
                
                // 展开/收起按钮
                Button(action: {
                    showFullLog.toggle()
                }) {
                    Image(systemName: showFullLog ? "chevron.down" : "chevron.up")
                        .font(.footnote)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.secondary.opacity(0.1))
            
            // 日志内容区
            if showFullLog {
                if filteredLogs.isEmpty {
                    Text("暂无日志记录")
                        .foregroundColor(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 4) {
                            ForEach(filteredLogs.prefix(100)) { entry in
                                logEntryView(entry)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                    }
                }
            } else {
                // 简洁模式：只显示最新的3条日志
                if filteredLogs.isEmpty {
                    Text("暂无日志记录")
                        .foregroundColor(.secondary)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(filteredLogs.prefix(3)) { entry in
                        logEntryView(entry)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                    }
                }
            }
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .frame(height: showFullLog ? 300 : 120)
        .animation(.easeInOut, value: showFullLog)
        .onAppear {
            startTimer()
            
            // 添加测试日志以确认日志视图工作正常
            debugLog("日志视图已初始化")
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    // 单条日志条目的视图
    private func logEntryView(_ entry: DebugLogger.LogEntry) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .center, spacing: 4) {
                // 日志级别指示器
                Circle()
                    .fill(logLevelColor(entry.level))
                    .frame(width: 8, height: 8)
                
                // 时间
                Text(entry.formattedTime)
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(.secondary)
                
                // 级别
                Text(entry.level.rawValue)
                    .font(.system(.caption2, design: .monospaced))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(logLevelColor(entry.level).opacity(0.1))
                    .foregroundColor(logLevelColor(entry.level))
                    .cornerRadius(3)
                
                Spacer()
                
                // 文件和行号
                Text("\(entry.file):\(entry.line)")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            
            // 消息内容
            Text(entry.message)
                .font(.system(.caption, design: .monospaced))
                .lineLimit(2)
                .padding(.leading, 12)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .contextMenu {
            Button("复制日志内容") {
                UIPasteboard.general.string = "\(entry.formattedTime) [\(entry.level.rawValue)] [\(entry.file):\(entry.line)] \(entry.message)"
            }
        }
    }
    
    // 根据日志级别选择颜色
    private func logLevelColor(_ level: LogLevel) -> Color {
        switch level {
        case .debug: return .gray
        case .info: return .blue
        case .warning: return .orange
        case .error: return .red
        }
    }
    
    // 过滤后的日志列表
    private var filteredLogs: [DebugLogger.LogEntry] {
        guard let level = filter else {
            return logs.reversed() // 最新的日志显示在顶部
        }
        
        return logs.filter { $0.level == level }.reversed()
    }
    
    // 启动定时刷新
    private func startTimer() {
        refreshLogs() // 立即刷新一次
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            refreshLogs()
        }
    }
    
    // 停止定时刷新
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // 刷新日志数据
    private func refreshLogs() {
        self.logs = DebugLogger.shared.logHistory
    }
}
