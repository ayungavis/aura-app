//
//  HeroSection.swift
//  AuraApp
//

import SwiftUI

extension ListView {
    struct HeroSection: View {
        let category: String
        var initialImage: UIImage? = nil
        var imageURL: URL? = nil
        var imageName: String? = nil
        
        var body: some View {
            ZStack {
                if let uiImage = initialImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else if let url = imageURL {
                    CachedAsyncImage(url: url) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    // Fallback to SF Symbol style matching Home page
                    ZStack {
                        Color(UIColor.systemGray5)
                        
                        Image(systemName: imageName ?? iconForCategory(category))
                            .resizable()
                            .scaledToFit()
                            .font(.system(size: 80, weight: .light))
                            .foregroundStyle(.black.opacity(0.1))
                            .frame(width: 120, height: 120)
                    }
                }
            }
            .frame(width: 240, height: 240)
            .clipped()
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
        
        private func iconForCategory(_ category: String) -> String {
            switch category.lowercased() {
            case "running": return "figure.run"
            case "biking": return "figure.outdoor.cycle"
            case "swimming": return "figure.pool.swim"
            case "hiking": return "figure.hiking"
            default: return "mappin.circle.fill"
            }
        }
    }
}

#Preview {
    ListView.HeroSection(category: "Running", initialImage: nil, imageURL: nil)
}
