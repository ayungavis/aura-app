//
//  WeatherDebugOverlay.swift
//  AuraApp
//
//  Debug tool for overriding weather conditions during development.
//  Presents a glassmorphic panel with toggles to force rain/sunny
//  and day/night states for testing weather effects.
//
//  This view is only intended for DEBUG builds.
//

import SwiftUI

struct WeatherDebugOverlay: View {
  @Binding var isPresented: Bool
  @Binding var overrideEnabled: Bool
  @Binding var overrideCondition: WeatherCondition
  @Binding var overrideIsDay: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      // Header
      HStack {
        Image(systemName: "gearshape.fill")
          .font(.system(size: 14, weight: .semibold))
        Text("Weather Debug")
          .font(.custom("InstrumentSans-SemiBold", size: 15))
        Spacer()
        Button {
          withAnimation(.spring(response: 0.3)) {
            isPresented = false
          }
        } label: {
          Image(systemName: "xmark.circle.fill")
            .font(.system(size: 20))
            .foregroundStyle(.secondary)
        }
      }
      .padding(.horizontal, 16)
      .padding(.top, 16)
      .padding(.bottom, 12)

      Divider().opacity(0.3)

      VStack(spacing: 16) {
        // Override toggle
        Toggle(isOn: $overrideEnabled) {
          Label("Override Condition", systemImage: "wrench.and.screwdriver")
            .font(.custom("InstrumentSans-Medium", size: 14))
        }
        .tint(.purple)

        if overrideEnabled {
          // Condition picker
          VStack(alignment: .leading, spacing: 8) {
            Text("Condition")
              .font(.custom("InstrumentSans-Medium", size: 12))
              .foregroundStyle(.secondary)

            HStack(spacing: 8) {
              conditionButton(.clearSky, icon: "sun.max.fill", label: "Sunny")
              conditionButton(.partlyCloudy, icon: "cloud.sun.fill", label: "Cloudy")
              conditionButton(.rainModerate, icon: "cloud.rain.fill", label: "Rain")
              conditionButton(.thunderstorm, icon: "cloud.bolt.rain.fill", label: "Storm")
            }
          }

          // Day/Night toggle
          Toggle(isOn: $overrideIsDay) {
            Label(
              overrideIsDay ? "Daytime" : "Nighttime",
              systemImage: overrideIsDay ? "sun.max.fill" : "moon.stars.fill"
            )
            .font(.custom("InstrumentSans-Medium", size: 14))
          }
          .tint(.purple)
        }
      }
      .padding(16)
    }
    .background(.ultraThinMaterial)
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
    .padding(.horizontal, 16)
    .transition(.asymmetric(
      insertion: .move(edge: .top).combined(with: .opacity),
      removal: .opacity
    ))
  }

  private func conditionButton(
    _ condition: WeatherCondition,
    icon: String,
    label: String
  ) -> some View {
    Button {
      withAnimation(.spring(response: 0.2)) {
        overrideCondition = condition
      }
    } label: {
      VStack(spacing: 4) {
        Image(systemName: icon)
          .font(.system(size: 18))
        Text(label)
          .font(.custom("InstrumentSans-Regular", size: 10))
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 8)
      .background(
        overrideCondition == condition
          ? Color.purple.opacity(0.2)
          : Color.clear
      )
      .clipShape(RoundedRectangle(cornerRadius: 8))
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .stroke(
            overrideCondition == condition
              ? Color.purple : Color.clear,
            lineWidth: 1.5
          )
      )
    }
    .buttonStyle(.plain)
  }
}
