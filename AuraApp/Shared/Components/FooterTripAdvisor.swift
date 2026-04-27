//
//  FooterTripAdvisor.swift
//  AuraApp
//
//  Shared component for TripAdvisor branding attribution.
//

import SwiftUI

struct FooterTripAdvisor: View {
  var body: some View {
    HStack(spacing: 6) {
      Text("Powered by")
        .font(.custom("InstrumentSans-Regular", size: 14))
        .foregroundStyle(.secondary.opacity(0.8))

      Image("logo-tripadvisor")
        .resizable()
        .scaledToFit()
        .frame(height: 14)
    }
    .frame(maxWidth: .infinity)
  }
}

#Preview {
  FooterTripAdvisor()
}
