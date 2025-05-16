//
//  SearchService.swift
//  dnbExample
//
//  Created by simons on 2025/5/16.
//

// SearchService.swift
// 搜索服务 - 处理位置搜索请求

import Foundation
import MapKit
import Combine

class SearchService {
    // 本地搜索请求
    private var searchCompleter = MKLocalSearchCompleter()
    private var currentSearch: MKLocalSearch?
    
    // 搜索区域设置 (可选，不设置则全球范围)
    var searchRegion: MKCoordinateRegion?
    

    
    // 搜索位置
    func searchLocations(query: String) -> AnyPublisher<[LocationSearchResult], Error> {
        infoLog("设置搜索位置")
        return Future<[LocationSearchResult], Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "SearchService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Service instance was deallocated"])))
                return
            }
            
            // 检查搜索查询是否为空
            guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                promise(.success([]))
                return
            }
            
            // 取消之前的搜索
            self.currentSearch?.cancel()
    
            
            // 创建搜索请求
            let searchRequest = MKLocalSearch.Request()
            searchRequest.naturalLanguageQuery = query
            
            // 设置搜索区域 (如果有)
            if let region = self.searchRegion {
                
                searchRequest.region = region
            }
            
            // 执行搜索
            infoLog("开始执行搜索")
            let search = MKLocalSearch(request: searchRequest)
            self.currentSearch = search
            
            search.start { response, error in
                // 检查错误
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                // 处理响应结果
                guard let response = response else {
                    promise(.success([]))
                    return
                }
                
                // 映射响应项到搜索结果模型
                let results = response.mapItems.map { item -> LocationSearchResult in
                    let placemark = item.placemark
                    
                    // 格式化地址
                    let address = [
                        placemark.thoroughfare,
                        placemark.locality,
                        placemark.administrativeArea,
                        placemark.country
                    ]
                    .compactMap { $0 }
                    .joined(separator: ", ")
                    
                    return LocationSearchResult(
                        name: item.name ?? placemark.name ?? "未知位置",
                        address: address.isEmpty ? nil : address,
                        coordinate: placemark.coordinate
                    )
                }
                
                promise(.success(results))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // 通过坐标反向查找位置
    func reverseGeocode(coordinate: CLLocationCoordinate2D) -> AnyPublisher<LocationSearchResult?, Error> {
        return Future<LocationSearchResult?, Error> { promise in
            let geocoder = CLGeocoder()
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                guard let placemark = placemarks?.first else {
                    // 没有找到地址信息，返回坐标点
                    let result = LocationSearchResult(
                        name: "位置点",
                        address: String(format: "%.6f, %.6f", coordinate.latitude, coordinate.longitude),
                        coordinate: coordinate
                    )
                    promise(.success(result))
                    return
                }
                
                // 格式化地址
                let address = [
                    placemark.thoroughfare,
                    placemark.subThoroughfare,
                    placemark.locality,
                    placemark.subLocality,
                    placemark.administrativeArea,
                    placemark.postalCode,
                    placemark.country
                ]
                .compactMap { $0 }
                .joined(separator: ", ")
                
                // 尝试获取位置名称
                let name = placemark.name ?? placemark.thoroughfare ?? placemark.locality ?? "位置点"
                
                // 创建结果
                let result = LocationSearchResult(
                    name: name,
                    address: address,
                    coordinate: coordinate
                )
                
                promise(.success(result))
            }
        }
        .eraseToAnyPublisher()
    }
}
