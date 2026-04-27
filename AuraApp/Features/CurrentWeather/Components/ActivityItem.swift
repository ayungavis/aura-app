//
//  ActivityItem.swift
//  AuraApp
//
//  A card component that displays a recommendation with an SF Symbol icon.
//  Previously used bundled images — now uses SF Symbols for dynamic content.
//  SF Symbols are Apple's built-in icon library that scales to all sizes.
//

import SwiftUI

struct ActivityItem: View {
  let title: String
  let subtitle: String
  let systemImageName: String

  var body: some View {
    ZStack {
      // Background: SF Symbol icon with dither effect overlay
      Image(systemName: systemImageName)
        .resizable()
        .scaledToFit()
        .font(.system(size: 60, weight: .light))
        .foregroundStyle(.black.opacity(0.15))
        .frame(width: 141, height: 141)
        .background(Color(red: 245/255, green: 245/255, blue: 245/255))

      // Bottom section: title and subtitle overlay
      Layout(direction: .vertical, justify: .end, height: .fill) {
        RoundedRectangle(cornerRadius: 0)
          .fill(
            LinearGradient(
              colors: [.white, .white.opacity(0)],
              startPoint: .bottom,
              endPoint: .top
            )
          ).frame(height: .infinity)

        Layout(
          direction: .horizontal,
          justify: .spaceBetween,
          align: .center,
          horizontalPadding: 10,
          width: .fill,
          height: .fixed(32)
        ) {
          CustomText(title, variant: .caption)

          Spacer()

          CustomText(
            subtitle,
            variant: .custom(family: .serif, weight: .regular, size: 10, style: .caption)
          )
        }
        .background(.white)
      }
    }
    .border(.border, width: 0.2)
    .frame(width: 141, height: 141)
  }
}

#Preview {
  ActivityItem(title: "Running", subtitle: "Great weather", systemImageName: "figure.run")
}
