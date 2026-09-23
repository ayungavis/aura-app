//
//  ActivityItem.swift
//  AuraApp
//
//  A card component that displays a recommendation with a tinted SF Symbol.
//  When an AI-generated image is available (from Image Playground),
//  it overlays the SF Symbol with the generated image.
//

import SwiftUI

struct ActivityItem: View {
  let title: String
  let subtitle: String
  let systemImageName: String
  var imageURL: URL? = nil
  var generatedImage: UIImage? = nil
  var isGenerationFailed: Bool = false
  /// iOS 27+: shows a Generate button that opens the Image Playground sheet.
  var onGenerate: (() -> Void)? = nil
  /// Position in its row; picks the pastel so neighbouring cards always differ.
  var paletteIndex: Int = 0

  private var palette: CardPalette { CardPalette.at(paletteIndex) }

  var body: some View {
    ZStack {
      // Background: tinted gradient + symbol, shown until (or instead of) an image.
      ZStack {
        LinearGradient(
          colors: [palette.top, palette.bottom],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )

        VStack(spacing: 8) {
          if generatedImage == nil {
            if let onGenerate {
              Button(action: onGenerate) {
                HStack(spacing: 4) {
                  Image(systemName: "sparkles")
                    .font(.system(size: 8))
                  Text("Generate")
                    .font(.custom("InstrumentSans-Regular", size: 8))
                }
                .foregroundStyle(palette.ink)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.white.opacity(0.7), in: Capsule())
              }
              .buttonStyle(.plain)
            } else if !isGenerationFailed && CurrentWeatherViewModel.supportsBackgroundImageGeneration {
              // A failure just leaves the symbol: on devices without Image
              // Playground an error label on every card reads as a broken app.
              HStack(spacing: 4) {
                ProgressView()
                  .scaleEffect(0.6)
                  .tint(palette.ink)
                Text("Generating...")
                  .font(.custom("InstrumentSans-Regular", size: 8))
                  .foregroundStyle(palette.ink.opacity(0.7))
              }
            }
          }

          Image(systemName: systemImageName)
            .resizable()
            .scaledToFit()
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(palette.ink)
            .frame(width: 52, height: 52)
        }
        .offset(y: -15) // Offset upwards to stay clear of the bottom text background
      }
      .frame(width: 141, height: 141)

      // Generated Image Overlay (from Image Playground)
      if let uiImage = generatedImage {
        Image(uiImage: uiImage)
          .resizable()
          .scaledToFill()
          .frame(width: 141, height: 141)
          .clipped()
          .transition(.opacity.animation(.easeIn(duration: 0.3)))
      }

      // Bottom section: title and subtitle overlay
      Layout(direction: .vertical, justify: .end, height: .fill) {
        Rectangle()
          .fill(
            LinearGradient(
              colors: [.white, .white.opacity(0)],
              startPoint: .bottom,
              endPoint: .top
            )
          )
          .frame(height: 50)

        Layout(
          direction: .vertical,
          justify: .center,
          align: .leading,
          horizontalPadding: 10,
          width: .fill,
          height: .fixed(40)
        ) {
          CustomText(title, variant: .caption)
            .lineLimit(1)

          CustomText(
            subtitle,
            variant: .custom(family: .serif, weight: .regular, size: 9, style: .caption)
          )
          .lineLimit(1)
          .opacity(0.6)
        }
        .background(.white)
      }
    }
    .border(Color.black.opacity(0.05), width: 0.5)
    .frame(width: 141, height: 141)
  }
}

// MARK: - Palette

/// Soft pastel backgrounds for cards without an image.
struct CardPalette {
  let top: Color
  let bottom: Color
  let ink: Color

  private static let all: [CardPalette] = [
    CardPalette(top: Color(hex: "#EDE7FF"), bottom: Color(hex: "#D6CCFF"), ink: Color(hex: "#6B55D9")), // lavender
    CardPalette(top: Color(hex: "#FFEBDD"), bottom: Color(hex: "#FFD3B8"), ink: Color(hex: "#D2693A")), // peach
    CardPalette(top: Color(hex: "#E2F6EC"), bottom: Color(hex: "#C4EBD6"), ink: Color(hex: "#2F8F60")), // mint
    CardPalette(top: Color(hex: "#E3F0FF"), bottom: Color(hex: "#C7DEFF"), ink: Color(hex: "#3B72D1")), // sky
    CardPalette(top: Color(hex: "#FFE6EE"), bottom: Color(hex: "#FFCCDC"), ink: Color(hex: "#C8436F")), // rose
    CardPalette(top: Color(hex: "#FFF5D6"), bottom: Color(hex: "#FFE8A8"), ink: Color(hex: "#B07D0E")), // butter
  ]

  static func at(_ index: Int) -> CardPalette {
    all[index % all.count]
  }
}

#Preview {
  ActivityItem(title: "Running", subtitle: "Great weather", systemImageName: "figure.run")
}
