//
//  LocationService.swift
//  dnbExample
//
//  Created by simons on 2025/5/16.
//

// LocationService.swift
// 处理位置获取和地理编码

import Foundation
import CoreLocation
import Combine

enum LocationError: Error {
    case authorizationDenied
    case locationUnknown
    case geocodingFailed
    case general(Error)
    
    var description: String {
        switch self {
        case .authorizationDenied:
            return "位置权限被拒绝。请在设置中允许应用获取您的位置。"
        case .locationUnknown:
            return "无法确定您的位置。请确保位置服务已开启。"
        case .geocodingFailed:
            return "无法获取位置详细地址。"
        case .general(let error):
            return "发生错误: \(error.localizedDescription)"
        }
    }
}

class LocationService: NSObject, ObservableObject {
    
    // 位置管理器
    private let locationManager = CLLocationManager()
    
    // 地理编码器
    private let geocoder = CLGeocoder()
    
    // 发布者
    private let locationSubject = PassthroughSubject<CLLocation, LocationError>()
    
    // 组合取消存储
    private var cancellables = Set<AnyCancellable>()
    
    // 位置结果发布者
    var locationPublisher: AnyPublisher<Location, LocationError> {
        return locationSubject
            .flatMap { [weak self] location -> AnyPublisher<Location, LocationError> in
                guard let self = self else {
                    return Fail(error: LocationError.general(NSError()))
                        .eraseToAnyPublisher()
                }
                
                return self.performReverseGeocode(for: location)
            }
            .eraseToAnyPublisher()
    }
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10  // 10米移动距离触发更新
    }
    
    // 开始更新位置
    func startUpdatingLocation() {
        let authStatus = locationManager.authorizationStatus
        
        switch authStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            locationSubject.send(completion: .failure(.authorizationDenied))
        @unknown default:
            locationSubject.send(completion: .failure(.general(NSError(domain: "LocationService", code: -1, userInfo: nil))))
        }
    }
    
    // 停止更新位置
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    // 请求一次位置更新
    func requestLocation() {
        infoLog("请求一次位置更新")
        let authStatus = locationManager.authorizationStatus
        
        switch authStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            locationSubject.send(completion: .failure(.authorizationDenied))
        @unknown default:
            locationSubject.send(completion: .failure(.general(NSError(domain: "LocationService", code: -1, userInfo: nil))))
        }
    }
    
    // 执行反向地理编码
    private func performReverseGeocode(for location: CLLocation) -> AnyPublisher<Location, LocationError> {
        infoLog("执行反向地理编码")
        return Future<Location, LocationError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.general(NSError())))
                return
            }
            
            self.geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    promise(.failure(.general(error)))
                    return
                }
                
                if let placemark = placemarks?.first {
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
                    
                    let userLocation = Location.userLocation(
                        coordinate: location.coordinate,
                        address: address.isEmpty ? nil : address
                    )
                    
                    promise(.success(userLocation))
                } else {
                    // 没有找到地址信息，但位置有效
                    let userLocation = Location.userLocation(coordinate: location.coordinate)
                    promise(.success(userLocation))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // 发布位置更新
        locationSubject.send(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                locationSubject.send(completion: .failure(.authorizationDenied))
            case .locationUnknown:
                locationSubject.send(completion: .failure(.locationUnknown))
            default:
                locationSubject.send(completion: .failure(.general(error)))
            }
        } else {
            locationSubject.send(completion: .failure(.general(error)))
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // 权限已获得，请求位置
            manager.requestLocation()
        case .denied, .restricted:
            locationSubject.send(completion: .failure(.authorizationDenied))
        case .notDetermined:
            // 等待用户响应权限请求
            break
        @unknown default:
            break
        }
    }
}
