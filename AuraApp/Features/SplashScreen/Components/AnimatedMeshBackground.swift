//
//  AnimatedMeshBackground.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 21/04/26.
//

import SwiftUI

struct AnimatedMeshBackground: View {
    private let width: Int = 4
    private let height: Int = 4

    private let colors: [Color] = [
        Color(red: 0.433, green: 0.283, blue: 0.785),
        Color(red: 0.600, green: 0.469, blue: 0.903),
        Color(red: 1.000, green: 0.902, blue: 0.804),
        Color(red: 0.433, green: 0.283, blue: 0.785),

        Color(red: 0.433, green: 0.283, blue: 0.785),
        Color(red: 0.433, green: 0.283, blue: 0.785),
        Color(red: 0.600, green: 0.469, blue: 0.903),
        Color(red: 1.000, green: 0.902, blue: 0.804),

        Color(red: 0.433, green: 0.283, blue: 0.785),
        Color(red: 0.433, green: 0.283, blue: 0.785),
        Color(red: 0.433, green: 0.283, blue: 0.785),
        Color(red: 0.600, green: 0.469, blue: 0.903),

        Color(red: 1.000, green: 0.902, blue: 0.804),
        Color(red: 0.433, green: 0.283, blue: 0.785),
        Color(red: 0.433, green: 0.283, blue: 0.785),
        Color(red: 0.433, green: 0.283, blue: 0.785),
    ]

    private let basePoints: [SIMD2<Float>] = [
        SIMD2(0.000, 0.000), SIMD2(0.478, 0.000), SIMD2(0.627, 0.000), SIMD2(1.000, 0.000),
        SIMD2(0.000, 0.326), SIMD2(0.426, 0.430), SIMD2(0.735, 0.136), SIMD2(1.000, 0.242),
        SIMD2(0.000, 0.605), SIMD2(0.358, 0.535), SIMD2(0.716, 0.631), SIMD2(1.000, 0.794),
        SIMD2(0.000, 1.000), SIMD2(0.208, 1.000), SIMD2(0.621, 1.000), SIMD2(1.000, 1.000),
    ]

    var body: some View {
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
        .ignoresSafeArea()
    }

    private func animatedPoints(for time: TimeInterval) -> [SIMD2<Float>] {
        var points = basePoints

        points[5].x += Float(sin(time * 0.8) * 0.15)
        points[5].y += Float(cos(time * 0.6) * 0.15)

        points[6].x += Float(sin(time * 0.5 + 1.0) * 0.20)
        points[6].y += Float(cos(time * 0.7 - 1.0) * 0.10)

        points[9].x += Float(cos(time * 0.6 + 2.0) * 0.15)
        points[9].y += Float(sin(time * 0.8 - 0.5) * 0.20)

        points[10].x += Float(cos(time * 0.4 - 1.5) * 0.20)
        points[10].y += Float(sin(time * 0.9 + 1.0) * 0.15)

        return points
    }
}

#Preview {
    AnimatedMeshBackground()
}
