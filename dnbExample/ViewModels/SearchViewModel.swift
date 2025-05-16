//
//  SidebarView.swift
//  dnbExample
//
//  Created by simons on 2025/5/16.
//


import Foundation
import MapKit
import Combine

// 搜索结果类型
enum SearchResultType {
    case location // 地图位置结果
    case history  // 历史搜索记录
}

// 位置搜索结果模型
struct LocationSearchResult: Identifiable {
    let id = UUID()
    let name: String
    let address: String?
    let coordinate: CLLocationCoordinate2D
    let type: SearchResultType
    
    init(name: String, address: String? = nil, coordinate: CLLocationCoordinate2D, type: SearchResultType = .location) {
        self.name = name
        self.address = address
        self.coordinate = coordinate
        self.type = type
    }
    
    // 转换为 Location 模型
    func toLocation() -> Location {
        return Location(name: self.name, coordinate: self.coordinate, address: self.address)
    }
}

class SearchViewModel: ObservableObject {
    // 用户输入
    @Published var searchText: String = ""
    
    // 搜索结果
    @Published var searchResults: [LocationSearchResult] = []
    
    // 搜索历史
    @Published var searchHistory: [LocationSearchResult] = []
    
    // 加载状态
    @Published var isLoading: Bool = false
    
    // 错误信息
    @Published var errorMessage: String?
    
    // 服务
    private let searchService: SearchService
    
    // 当前位置选择回调
    var onLocationSelected: ((Location) -> Void)?
    
    // 防抖计时器
    private var searchDebounce: Timer?
    
    // 订阅存储
    private var cancellables = Set<AnyCancellable>()
    
    // 最大历史记录数
    private let maxHistoryCount = 5
    
    init(searchService: SearchService = SearchService()) {
        self.searchService = searchService
        loadSearchHistory()
    }
    
    // 搜索位置
    func searchLocations() {
        // 取消之前的延迟搜索
        searchDebounce?.invalidate()
        
        // 显示加载状态
        isLoading = true
        errorMessage = nil
        
        // 使用服务执行搜索
        searchService.searchLocations(query: searchText)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                    print("搜索错误: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] results in
                guard let self = self else { return }
                self.isLoading = false
                
                // 合并搜索结果和历史记录
                if self.searchText.isEmpty {
                    // 如果搜索文本为空，只显示历史记录
                    self.searchResults = self.searchHistory
                } else {
                    // 显示搜索结果，可能包括匹配的历史记录
                    var combinedResults = results
                    
                    // 如果历史记录中有匹配的项，将其添加到前面
                    let matchingHistory = self.searchHistory.filter {
                        $0.name.localizedCaseInsensitiveContains(self.searchText) ||
                        ($0.address?.localizedCaseInsensitiveContains(self.searchText) ?? false)
                    }
                    
                    if !matchingHistory.isEmpty {
                        combinedResults.insert(contentsOf: matchingHistory, at: 0)
                    }
                    
                    self.searchResults = combinedResults
                }
            })
            .store(in: &cancellables)
    }
    
    // 选择位置
    func selectLocation(_ searchResult: LocationSearchResult) {
        // 转换为位置模型
        let location = searchResult.toLocation()
        
        // 添加到历史记录
        addToHistory(searchResult)
        
        // 调用回调
        onLocationSelected?(location)
        
        // 清空搜索文本
        searchText = ""
    }
    
    // 清空结果
    func clearResults() {
        searchResults = []
    }
    
    // 添加到历史记录
    private func addToHistory(_ result: LocationSearchResult) {
        // 创建新的历史项 (避免直接使用搜索结果，保证ID不同)
        let historyItem = LocationSearchResult(
            name: result.name,
            address: result.address,
            coordinate: result.coordinate,
            type: .history
        )
        
        // 移除已存在的相同位置
        searchHistory.removeAll { $0.name == result.name && $0.address == result.address }
        
        // 添加到头部
        searchHistory.insert(historyItem, at: 0)
        
        // 限制历史记录数量
        if searchHistory.count > maxHistoryCount {
            searchHistory = Array(searchHistory.prefix(maxHistoryCount))
        }
        
        // 保存历史记录
        saveSearchHistory()
    }
    
    // 清空历史记录
    func clearHistory() {
        searchHistory = []
        saveSearchHistory()
    }
    
    // 保存历史记录到 UserDefaults
    private func saveSearchHistory() {
        let historyData = searchHistory.map { result -> [String: Any] in
            return [
                "name": result.name,
                "address": result.address ?? "",
                "latitude": result.coordinate.latitude,
                "longitude": result.coordinate.longitude
            ]
        }
        
        UserDefaults.standard.set(historyData, forKey: "searchHistory")
    }
    
    // 从 UserDefaults 加载历史记录
    private func loadSearchHistory() {
        guard let historyData = UserDefaults.standard.array(forKey: "searchHistory") as? [[String: Any]] else {
            return
        }
        
        searchHistory = historyData.compactMap { data -> LocationSearchResult? in
            guard
                let name = data["name"] as? String,
                let address = data["address"] as? String,
                let latitude = data["latitude"] as? Double,
                let longitude = data["longitude"] as? Double
            else {
                return nil
            }
            
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            return LocationSearchResult(
                name: name,
                address: address.isEmpty ? nil : address,
                coordinate: coordinate,
                type: .history
            )
        }
    }
    
    // 显示搜索历史
    func showSearchHistory() {
        searchResults = searchHistory
    }
}
