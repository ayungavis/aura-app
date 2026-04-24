//
//  CurrentTemperature.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 21/04/26.
//

import SwiftUI
import WeatherKit

struct CurrentTemperature: View {
    let weather: CurrentWeather?
    let locationName: String?

    var body: some View {
        Layout(direction: .vertical, horizontalPadding: 20) {
            CustomText(conditionDescription, variant: .caption, color: .black)
                .opacity(0.56)

            CustomText(
                temperatureString,
                variant: .custom(
                    family: .serif,
                    weight: .regular,
                    size: 96,
                    style: .largeTitle
                )
            )

            Layout(direction: .horizontal, spacing: 4) {
                Image(systemName: "location")
                CustomText(locationName ?? "Locating...")
            }
        }
    }

    private var temperatureString: String {
        guard let weather else { return "--°" }
        return weather.temperature.formatted(.measurement(numberFormatStyle: .number.precision(.fractionLength(0))))
    }

    private var conditionDescription: String {
        weather?.condition.description.capitalized ?? "Loading..."
    }
}

#Preview {
    CurrentTemperature(weather: nil, locationName: "Kabupaten Badung")
}
