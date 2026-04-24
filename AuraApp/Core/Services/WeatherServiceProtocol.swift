//
//  WeatherServiceProtocol.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 23/04/26.
//

import CoreLocation

protocol WeatherServiceProtocol: AnyObject {
  func fetchWeatherData(for location: CLLocation) async throws -> WeatherResponse
}
