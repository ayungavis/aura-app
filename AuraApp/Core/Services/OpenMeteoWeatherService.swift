//
//  OpenMeteoWeatherService.swift
//  AuraApp
//

import CoreLocation
import OpenMeteoSdk

@MainActor
class OpenMeteoWeatherService: WeatherServiceProtocol {
    static let shared = OpenMeteoWeatherService()

    private let baseURL = "https://api.open-meteo.com/v1/forecast"
    private let cache = LocalCache.shared

    func fetchWeatherData(for location: CLLocation) async throws -> WeatherResponse {
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        let cacheKey = "weather_\(String(format: "%.2f", lat))_\(String(format: "%.2f", lon))"

        if let cached = cache.load(key: cacheKey, as: WeatherResponse.self, expiration: 15 * 60) {
            AppLogger.cacheHit(cacheKey)
            return cached
        }

        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: "\(lat)"),
            URLQueryItem(name: "longitude", value: "\(lon)"),
            URLQueryItem(name: "current", value: "temperature_2m,apparent_temperature,relative_humidity_2m,weather_code,wind_speed_10m,wind_direction_10m,is_day"),
            URLQueryItem(name: "hourly", value: "temperature_2m,weather_code,relative_humidity_2m,wind_speed_10m"),
            URLQueryItem(name: "timezone", value: "auto"),
            URLQueryItem(name: "forecast_hours", value: "24"),
            URLQueryItem(name: "format", value: "flatbuffers"),
        ]

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        AppLogger.networkRequest("openMeteoWeather: \(lat), \(lon)")

        let responses = try await WeatherApiResponse.fetch(url: url)

        guard let response = responses.first else {
            throw URLError(.cannotParseResponse)
        }

        let weatherResponse = parseResponse(response)
        AppLogger.weatherUpdate(weatherResponse.current.condition.description)
        cache.save(weatherResponse, key: cacheKey)
        AppLogger.cacheSave(cacheKey)

        return weatherResponse
    }

    // current param order: temperature_2m(0), apparent_temperature(1), relative_humidity_2m(2),
    //   weather_code(3), wind_speed_10m(4), wind_direction_10m(5), is_day(6)
    // hourly param order: temperature_2m(0), weather_code(1), relative_humidity_2m(2), wind_speed_10m(3)
    private func parseResponse(_ response: WeatherApiResponse) -> WeatherResponse {
        let utcOffset = response.utcOffsetSeconds
        let current = response.current!

        let currentWeather = CurrentWeatherData(
            temperature: Double(current.variables(at: 0)!.value),
            apparentTemperature: Double(current.variables(at: 1)!.value),
            humidity: Int(current.variables(at: 2)!.value),
            windSpeed: Double(current.variables(at: 4)!.value),
            windDirection: Double(current.variables(at: 5)!.value),
            condition: WeatherCondition(wmoCode: Int(current.variables(at: 3)!.value)),
            isDay: current.variables(at: 6)!.value == 1.0
        )

        let hourly = response.hourly!
        let times = hourly.getDateTime(offset: utcOffset)
        let temperatures = hourly.variables(at: 0)!.values
        let weatherCodes = hourly.variables(at: 1)!.values
        let humidities = hourly.variables(at: 2)!.values
        let windSpeeds = hourly.variables(at: 3)!.values

        let hourlyData: [HourlyWeatherData] = (0..<times.count).map { i in
            HourlyWeatherData(
                date: times[i],
                temperature: Double(temperatures[i]),
                condition: WeatherCondition(wmoCode: Int(weatherCodes[i])),
                humidity: Int(humidities[i]),
                windSpeed: Double(windSpeeds[i])
            )
        }

        return WeatherResponse(current: currentWeather, hourly: hourlyData)
    }
}
