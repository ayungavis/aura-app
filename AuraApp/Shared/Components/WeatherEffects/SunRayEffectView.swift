//
//  SunRayEffectView.swift
//  AuraApp
//
//  Animated ambient purple rays using a Metal shader via ShaderLibrary.
//  Uses .colorEffect (not .layerEffect) since the shader takes
//  (position, color) and outputs a new color per pixel.
//

import SwiftUI

struct SunRayEffectView: View {
    @State private var startTime = Date()
    
    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsed = Float(timeline.date.timeIntervalSince(startTime))
            
            // Use a white rectangle so the shader has opaque pixels to work with.
            // The shader replaces the color entirely, using color.a to know
            // the source is visible.
            Rectangle()
                .fill(.white)
                .visualEffect { content, proxy in
                    content
                        .colorEffect(
                            ShaderLibrary.sunRays(
                                .float(elapsed),
                                .float2(proxy.size)
                            )
                        )
                }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}

#Preview {
    ZStack {
        Color.black
        SunRayEffectView()
    }
}
