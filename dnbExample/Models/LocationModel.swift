//
//  LocationModel.swift
//  dnbExample
//
//  Created by simons on 2025/5/16.
//

// LocationModel.swift
// 定义位置相关的数据结构

import Foundation
import CoreLocation
import MapKit

struct Location: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let address: String?
    
    init(name: String, coordinate: CLLocationCoordinate2D, address: String? = nil) {
        self.name = name
        self.coordinate = coordinate
        self.address = address
    }
    
    // 用户当前位置的工厂方法
    static func userLocation(coordinate: CLLocationCoordinate2D, address: String? = nil) -> Location {
        return Location(name: "我的位置", coordinate: coordinate, address: address)
    }
}

// 地图区域状态
struct MapRegion {
    var center: CLLocationCoordinate2D
    var span: MKCoordinateSpan
    
    // 默认初始化为北京中心
    init(center: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 39.9042, longitude: 116.4074),
         span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)) {
        self.center = center
        self.span = span
    }
    
    // 根据位置创建地图区域
    static func region(for location: CLLocation, spanDelta: Double = 0.01) -> MapRegion {
        return MapRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: spanDelta, longitudeDelta: spanDelta)
        )
    }
}
