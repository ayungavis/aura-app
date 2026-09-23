//
//  ActivityItem.swift
//  AuraApp
//
//  A card component that displays a recommendation with an SF Symbol icon.
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

  var body: some View {
    ZStack {
      // Background: SF Symbol icon (Fallback/Placeholder)
      ZStack {
        Color(red: 245/255, green: 245/255, blue: 245/255)
        
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
                .foregroundStyle(.black.opacity(0.5))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.black.opacity(0.05), in: Capsule())
              }
              .buttonStyle(.plain)
            } else if !isGenerationFailed && CurrentWeatherViewModel.supportsBackgroundImageGeneration {
              // A failure just leaves the SF Symbol: on devices without Image
              // Playground an error label on every card reads as a broken app.
              HStack(spacing: 4) {
                ProgressView()
                  .scaleEffect(0.6)
                Text("Generating...")
                  .font(.custom("InstrumentSans-Regular", size: 8))
                  .foregroundStyle(.black.opacity(0.3))
              }
            }
          }

          Image(systemName: systemImageName)
            .resizable()
            .scaledToFit()
            .font(.system(size: 40, weight: .light))
            .foregroundStyle(.black.opacity(0.1))
            .frame(width: 60, height: 60)
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

#Preview {
  ActivityItem(title: "Running", subtitle: "Great weather", systemImageName: "figure.run")
}
