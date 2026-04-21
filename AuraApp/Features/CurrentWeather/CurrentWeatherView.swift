//
//  CurrentWeatherView.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 21/04/26.
//

import SwiftUI

struct CurrentWeatherView: View {
    var body: some View {
        ZStack {
            Layout(direction: .vertical, justify: .start) {
                Layout(direction: .horizontal, justify: .start, horizontalPadding: 0) {
                    CurrentTemperature()
                }
            }
        }
    }
}

#Preview {
    CurrentWeatherView()
}
