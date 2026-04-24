//
//  WeatherService.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 23/04/26.
//

import CoreLocation
import WeatherKit

@MainActor
class WeatherService: WeatherServiceProtocol {
    static let shared = WeatherService()

    private let service = WeatherKit.WeatherService.shared

    func fetchWeatherData(for location: CLLocation) async throws -> Weather {
        let weather = try await service.weather(for: location)
        AppLogger.weatherUpdate(weather.currentWeather.condition.description)
        return weather
    }
}
