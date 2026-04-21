//
//  SplashScreenView.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 21/04/26.
//

import SwiftUI

struct SplashScreenView: View {
    private let width: Int = 4
    private let height: Int = 4
    
    private let colors: [Color] = [
        Color(red: 0.433, green: 0.283, blue: 0.785), Color(red: 0.600, green: 0.469, blue: 0.903), Color(red: 1, green: 0.902, blue: 0.804), Color(red: 0.433, green: 0.283, blue: 0.785),
        Color(red: 0.433, green: 0.283, blue: 0.785), Color(red: 0.433, green: 0.283, blue: 0.785), Color(red: 0.600, green: 0.469, blue: 0.903), Color(red: 1, green: 0.902, blue: 0.804),
        Color(red: 0.433, green: 0.283, blue: 0.785), Color(red: 0.433, green: 0.283, blue: 0.785), Color(red: 0.433, green: 0.283, blue: 0.785), Color(red: 0.600, green: 0.469, blue: 0.903),
        Color(red: 1, green: 0.902, blue: 0.804), Color(red: 0.433, green: 0.283, blue: 0.785), Color(red: 0.433, green: 0.283, blue: 0.785), Color(red: 0.433, green: 0.283, blue: 0.785)
    ]
    
    private let basePoints: [SIMD2<Float>] = [
        SIMD2<Float>(0.0, 0.0), SIMD2<Float>(0.478, 0.0), SIMD2<Float>(0.627, 0.0), SIMD2<Float>(1.0, 0.0),
        SIMD2<Float>(0.0, 0.326), SIMD2<Float>(0.426, 0.430), SIMD2<Float>(0.735, 0.136), SIMD2<Float>(1.0, 0.242),
        SIMD2<Float>(0.0, 0.605), SIMD2<Float>(0.358, 0.535), SIMD2<Float>(0.716, 0.631), SIMD2<Float>(1.0, 0.794),
        SIMD2<Float>(0.0, 1.0), SIMD2<Float>(0.208, 1.0), SIMD2<Float>(0.621, 1.0), SIMD2<Float>(1.0, 1.0)
    ]

    var body: some View {
        ZStack {
            // TimelineView updates continuously, creating a fluid animation
            TimelineView(.animation) { timeline in
                let time = timeline.date.timeIntervalSinceReferenceDate
                
                MeshGradient(
                    width: width,
                    height: height,
                    points: animatedPoints(for: time),
                    colors: colors,
                    background: .white,
                    smoothsColors: true,
                    colorSpace: .device
                )
            }
            
            Text("Aura")
        }
        .ignoresSafeArea()
    }
    
    /// Function to calculate moving points based on time
    private func animatedPoints(for time: TimeInterval) -> [SIMD2<Float>] {
        var points = basePoints
        
        // We only animate the 4 inner points (indices 5, 6, 9, 10).
        // By using sine/cosine with different multipliers, they move independently.
        
        // Inner point 1
        points[5].x += Float(sin(time * 0.8) * 0.15)
        points[5].y += Float(cos(time * 0.6) * 0.15)
        
        // Inner point 2
        points[6].x += Float(sin(time * 0.5 + 1.0) * 0.2)
        points[6].y += Float(cos(time * 0.7 - 1.0) * 0.1)
        
        // Inner point 3
        points[9].x += Float(cos(time * 0.6 + 2.0) * 0.15)
        points[9].y += Float(sin(time * 0.8 - 0.5) * 0.2)
        
        // Inner point 4
        points[10].x += Float(cos(time * 0.4 - 1.5) * 0.2)
        points[10].y += Float(sin(time * 0.9 + 1.0) * 0.15)
        
        return points
    }
}

#Preview {
    SplashScreenView()
}
