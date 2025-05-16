//
//  SearchBarView.swift
//  dnbExample
//
//  Created by simons on 2025/5/16.
//

// SearchBarView.swift
// 顶部搜索栏视图组件

import SwiftUI

struct SearchBarView: View {
    @ObservedObject var viewModel: SearchViewModel
    
    // 外部状态传递
    @Binding var isSearching: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                // 搜索图标和输入框
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(viewModel.searchText.isEmpty ? .gray : .blue)
                        .font(.system(size: 14))
                        .padding(.leading, 8)
                    
                    TextField("搜索位置...", text: $viewModel.searchText)
                        .font(.system(size: 14))
                        .submitLabel(.search)
                        .onSubmit {
                            if !viewModel.searchText.isEmpty {
                                viewModel.searchLocations()
                            }
                        }
//                        .onChange(of: viewModel.searchText) { _ in
//                            if viewModel.searchText.isEmpty {
//                                // 清空搜索结果
//                                viewModel.clearResults()
//                            }
//                        }
                    
                    
                    // iOS 17兼容的修复代码:
                    #if swift(>=5.9) && canImport(SwiftUI) && os(iOS) && compiler(>=5.9)
                    // 在 iOS 17 及以上使用新 API
                    .onChange(of: viewModel.searchText) {
                        if viewModel.searchText.isEmpty {
                            // 清空搜索结果
                            viewModel.clearResults()
                        }
                    }
                    #else
                    // 在旧版本 iOS 中使用旧 API
                    .onChange(of: viewModel.searchText) { _ in
                        if viewModel.searchText.isEmpty {
                            // 清空搜索结果
                            viewModel.clearResults()
                        }
                    }
                    #endif
                    
                    // 清除按钮
                    if !viewModel.searchText.isEmpty {
                        Button(action: {
                            viewModel.searchText = ""
                            viewModel.clearResults()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: 14))
                        }
                        .padding(.trailing, 8)
                    }
                }
                .padding(8)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                
                // 取消按钮 (仅在搜索时显示)
                if isSearching {
                    Button("取消") {
                        viewModel.searchText = ""
                        viewModel.clearResults()
                        // 关闭搜索模式
                        withAnimation {
                            isSearching = false
                        }
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    .padding(.leading, 8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            // 搜索结果列表
            if !viewModel.searchResults.isEmpty && isSearching {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(viewModel.searchResults, id: \.id) { result in
                            SearchResultRow(result: result) {
                                // 点击搜索结果
                                viewModel.selectLocation(result)
                                // 关闭搜索模式
                                withAnimation {
                                    isSearching = false
                                }
                            }
                            
                            if result.id != viewModel.searchResults.last?.id {
                                Divider()
                                    .padding(.leading, 40)
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .padding(.horizontal, 16)
                .frame(height: min(CGFloat(viewModel.searchResults.count * 60), 300))
            }
        }
        .background(Color(UIColor.systemBackground).opacity(0.8))
    }
}

// 搜索结果行
struct SearchResultRow: View {
    let result: LocationSearchResult
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // 位置图标
                Image(systemName: result.type == .history ? "clock" : "mappin.circle.fill")
                    .foregroundColor(result.type == .history ? .gray : .red)
                    .font(.system(size: 22))
                    .frame(width: 24, height: 24)
                
                // 位置信息
                VStack(alignment: .leading, spacing: 2) {
                    Text(result.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    if let address = result.address, !address.isEmpty {
                        Text(address)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // 右侧箭头
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
