//
//  WeatherServiceProtocol.swift
//  AuraApp
//

import CoreLocation
import WeatherKit

protocol WeatherServiceProtocol: AnyObject {
    func fetchWeatherData(for location: CLLocation) async throws -> Weather
}
