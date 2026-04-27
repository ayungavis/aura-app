//
//  WeatherBackgroundEffect.swift
//  AuraApp
//
//  Container view that selects the appropriate weather effect
//  based on the current weather condition.
//

import SwiftUI

struct WeatherBackgroundEffect: View {
    let condition: WeatherCondition?
    
    var body: some View {
        Group {
            if let condition = condition {
                if condition.isRaining {
                    RainEffectView()
                        .transition(.opacity.animation(.easeInOut(duration: 1.0)))
                } else if condition.isSunny {
                    SunRayEffectView()
                        .transition(.opacity.animation(.easeInOut(duration: 1.0)))
                }
            }
        }
        .allowsHitTesting(false)
    }
}
