//
//  CurrentWeatherView.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 21/04/26.
//

import SwiftUI
import WeatherKit

struct CurrentWeatherView: View {
    @StateObject private var viewModel = CurrentWeatherViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            } else if let error = viewModel.error {
                errorView(error)
            } else {
                weatherContent
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
    }

    private var weatherContent: some View {
        ZStack {
            Layout(direction: .vertical, align: .leading, height: .fill) {
                Image("main-gradient-background")
                    .resizable()
                    .scaledToFit()
            }

            ScrollView {
                Layout(direction: .vertical, spacing: 50) {
                    Spacer().frame(height: 127)
                    CurrentTemperature(
                        weather: viewModel.currentWeather,
                        locationName: viewModel.locationName
                    )
                    HourlyForecast(forecasts: viewModel.hourlyForecast.isEmpty ? HOURLY_FORECAST_DATA : viewModel.hourlyForecast)
                    RecommendedActivities()
                    RecommendedFoods()
                    Spacer().frame(height: 20)
                }
            }
        }
        .ignoresSafeArea()
    }

    private func errorView(_ error: Error) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "cloud.sun.rain.fill")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Unable to load weather")
                .font(.custom("InstrumentSans-Medium", size: 18))
            Text(error.localizedDescription)
                .font(.custom("InstrumentSans-Regular", size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button("Try Again") {
                viewModel.retry()
            }
            .buttonStyle(.bordered)
        }
    }
}

#Preview {
    CurrentWeatherView()
}
