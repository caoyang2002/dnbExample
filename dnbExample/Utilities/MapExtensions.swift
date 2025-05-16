// MapExtensions.swift
// 地图相关的扩展工具

import Foundation
import MapKit
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - Location 扩展，转换为地图标注
extension Location {
    func toAnnotation() -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.title = name
        annotation.subtitle = address
        annotation.coordinate = coordinate
        return annotation
    }
}

// MARK: - 标注标识符包装器
// 避免直接扩展 MKPointAnnotation 遵守 Identifiable
class IdentifiablePointAnnotation: MKPointAnnotation, Identifiable {
    let id = UUID()
}

// MARK: - 地图状态类型
enum MapState {
    case idle
    case tracking
    case searching
    case locationSelected
}

// MARK: - MKMapView 表示器视图
#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
struct MapViewRepresentable: UIViewRepresentable {
    @Binding var region: MapRegion
    var annotations: [MKPointAnnotation]
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        
        // 设置地图类型
        mapView.mapType = .standard
        
        // 设置用户跟踪模式
        mapView.userTrackingMode = .follow
        
        // 启用缩放控制
        mapView.showsScale = true
        mapView.showsCompass = true
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // 更新地图区域
        let mapRegion = MKCoordinateRegion(
            center: region.center,
            span: region.span
        )
        mapView.setRegion(mapRegion, animated: true)
        
        // 更新标注
        updateAnnotations(in: mapView)
    }
    
    private func updateAnnotations(in mapView: MKMapView) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(annotations)
        
        // 如果只有一个标注，确保它可见
        if annotations.count == 1, let annotation = annotations.first {
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    // 协调器处理地图视图代理方法
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable
        
        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }
        
        // 自定义标注视图
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // 不为用户位置提供自定义视图
            if annotation is MKUserLocation {
                return nil
            }
            
            // 为普通标注提供自定义视图
            let identifier = "locationAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                
                // 标注样式
                if let markerView = annotationView as? MKMarkerAnnotationView {
                    markerView.markerTintColor = .blue
                    markerView.glyphImage = UIImage(systemName: "mappin.circle.fill")
                    
                    // 添加右侧按钮
                    let button = UIButton(type: .detailDisclosure)
                    markerView.rightCalloutAccessoryView = button
                }
            } else {
                annotationView?.annotation = annotation
            }
            
            return annotationView
        }
        
        // 处理标注点击
        func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
            // 标注被选中时的逻辑
        }
        
        // 处理标注信息按钮点击
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            // 信息按钮被点击时的逻辑
        }
    }
}

#elseif os(macOS)
// macOS 版本的地图表示器
struct MapViewRepresentable: NSViewRepresentable {
    @Binding var region: MapRegion
    var annotations: [MKPointAnnotation]
    
    func makeNSView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        
        // 设置地图类型
        mapView.mapType = .standard
        
        // 启用缩放控制
        mapView.showsZoomControls = true
        mapView.showsScale = true
        mapView.showsCompass = true
        
        return mapView
    }
    
    func updateNSView(_ mapView: MKMapView, context: Context) {
        // 更新地图区域
        let mapRegion = MKCoordinateRegion(
            center: region.center,
            span: region.span
        )
        mapView.setRegion(mapRegion, animated: true)
        
        // 更新标注
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(annotations)
        
        // 如果只有一个标注，确保它可见
        if annotations.count == 1, let annotation = annotations.first {
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    // 协调器处理地图视图代理方法
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable
        
        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }
        
        // 自定义标注视图
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // 不为用户位置提供自定义视图
            if annotation is MKUserLocation {
                return nil
            }
            
            // 为普通标注提供自定义视图
            let identifier = "locationAnnotation"
            var annotationView = mapView.makeAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
            // 为 macOS 配置标注样式
            if let markerView = annotationView as? MKMarkerAnnotationView {
                markerView.markerTintColor = .blue
            }
            
            return annotationView
        }
    }
}

// macOS 辅助扩展
extension MKMapView {
    func makeAnnotationView(annotation: MKAnnotation, reuseIdentifier: String) -> MKAnnotationView? {
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
        annotationView.canShowCallout = true
        return annotationView
    }
}
#endif
