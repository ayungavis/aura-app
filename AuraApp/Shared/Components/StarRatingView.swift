//
//  StarRatingView.swift
//  AuraApp
//

import SwiftUI

struct StarRatingView: View {
    let rating: Double
    var maxRating: Int = 5
    var font: Font? = nil
    var starSize: CGFloat? = nil
    var color: Color = .black
    var spacing: CGFloat = 2
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<maxRating, id: \.self) { index in
                let diff = rating - Double(index)
                let img = diff >= 0.75 ? Image(systemName: "star.fill") : (diff >= 0.25 ? Image(systemName: "star.leadinghalf.filled") : Image(systemName: "star"))
                
                if let size = starSize {
                    img.resizable()
                       .frame(width: size, height: size)
                       .foregroundColor(color)
                } else {
                    img.font(font ?? .body)
                       .foregroundColor(color)
                }
            }
        }
    }
}

#Preview {
    VStack {
        StarRatingView(rating: 3.5, font: .title)
        StarRatingView(rating: 4.8, starSize: 20, color: .yellow)
    }
}
