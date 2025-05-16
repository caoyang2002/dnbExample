//
//  MapAnnotationView.swift
//  dnbExample
//
//  Created by simons on 2025/5/16.
//

// MapAnnotationView.swift
// 自定义地图标注视图

import SwiftUI

struct MapAnnotationView: View {
    var title: String
    var subtitle: String?
    
    var body: some View {
        VStack(spacing: 0) {
            // 信息气泡
            VStack(alignment: .center, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
            
            // 指向图标的三角形
            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: 10))
                .foregroundColor(.white)
                .offset(y: -3)
            
            // 定位图标
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 36, height: 36)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                
                Circle()
                    .fill(Color.blue)
                    .frame(width: 16, height: 16)
            }
        }
    }
}

#if DEBUG
struct MapAnnotationView_Previews: PreviewProvider {
    static var previews: some View {
        MapAnnotationView(
            title: "我的位置",
            subtitle: "北京市朝阳区三里屯"
        )
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color.gray.opacity(0.2))
    }
}
#endif
