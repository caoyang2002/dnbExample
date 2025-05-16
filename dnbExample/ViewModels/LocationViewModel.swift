//
//  LocationViewModel.swift
//  dnbExample
//
//  Created by simons on 2025/5/16.
//

// LocationViewModel.swift
// 处理位置状态和业务逻辑

import Foundation
import Combine
import CoreLocation
import MapKit

class LocationViewModel: ObservableObject {
    // 发布状态
    @Published var currentLocation: Location?
    @Published var mapRegion: MapRegion
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthorized = false
    
    // 服务
    private let locationService: LocationService
    
    // 组合取消存储
    private var cancellables = Set<AnyCancellable>()
    
    init(locationService: LocationService = LocationService()) {
        self.locationService = locationService
        self.mapRegion = MapRegion()
        
        setupBindings()
    }
    
    private func setupBindings() {
        // 监听位置更新
        locationService.locationPublisher
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    self.isLoading = false
                    
                    if case .failure(let error) = completion {
                        self.errorMessage = error.description
                        
                        if case .authorizationDenied = error {
                            self.isAuthorized = false
                        }
                    }
                },
                receiveValue: { [weak self] location in
                    guard let self = self else { return }
                    self.isLoading = false
                    self.errorMessage = nil
                    self.currentLocation = location
                    self.isAuthorized = true
                    
                    // 更新地图区域以显示用户位置
                    self.mapRegion = MapRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                }
            )
            .store(in: &cancellables)
    }
    
    // 开始请求位置
    func requestLocation() {
        isLoading = true
        errorMessage = nil
        locationService.requestLocation()
    }
    
    // 开始持续更新位置
    func startUpdatingLocation() {
        isLoading = true
        errorMessage = nil
        locationService.startUpdatingLocation()
    }
    
    // 停止更新位置
    func stopUpdatingLocation() {
        locationService.stopUpdatingLocation()
    }
}
