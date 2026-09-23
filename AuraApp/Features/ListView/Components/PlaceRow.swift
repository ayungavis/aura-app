//
//  PlaceRow.swift
//  AuraApp
//

import SwiftUI

extension ListView {
  struct PlaceRow: View {
    let place: Place

    var body: some View {
      HStack(spacing: 16) {
        PlaceThumbnail(place: place)

        VStack(alignment: .leading, spacing: 4) {
          Text(place.name)
            .font(.custom("InstrumentSans-Medium", size: 12))
            .foregroundColor(.primary)
            .lineLimit(1)

          if let locality = place.locality {
            Text(locality)
              .font(.custom("InstrumentSans-Medium", size: 10))
              .foregroundColor(.secondary)
              .lineLimit(1)
          }

          Spacer()

          if let distance = place.distance {
            Text(Measurement(value: distance, unit: UnitLength.meters)
              .formatted(.measurement(width: .abbreviated, usage: .road)))
              .font(.custom("InstrumentSans-Medium", size: 10))
              .foregroundColor(.secondary)
          }
        }

        Spacer(minLength: 0)

        Image(systemName: "chevron.right")
          .font(.system(size: 12, weight: .medium))
          .foregroundStyle(.tertiary)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.vertical, 8)
      .contentShape(Rectangle())
    }
  }
}
