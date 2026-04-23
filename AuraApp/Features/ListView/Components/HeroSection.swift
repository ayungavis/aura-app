//
//  HeroSection.swift
//  AuraApp
//

import SwiftUI

extension ListView {
    struct HeroSection: View {
        let category: String
        
        var body: some View {
            Image(systemName: iconForCategory(category))
                .font(.system(size: 80))
                .foregroundColor(.black.opacity(0.8))
                .frame(width: 240, height: 240)
                .background(
                    Rectangle()
                        .fill(Color(UIColor.systemGray5))
                        .overlay(
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .opacity(0.1)
                        )
                )
                .cornerRadius(12)
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
    ListView.HeroSection(category: "Running")
}
