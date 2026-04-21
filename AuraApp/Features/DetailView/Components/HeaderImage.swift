//
//  HeaderImage.swift
//  AuraApp
//

import SwiftUI

extension DetailView {
    struct HeaderImage: View {
        let photos: [LocationPhoto]
        
        var body: some View {
            Group {
                if let firstPhoto = photos.first,
                   let urlString = firstPhoto.images?.large?.url,
                   let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Rectangle()
                            .fill(Color(UIColor.systemGray5))
                            .overlay(ProgressView())
                    }
                    .frame(width: UIScreen.main.bounds.width, height: 300)
                    .clipped()
                } else {
                    Rectangle()
                        .fill(Color(UIColor.systemGray5))
                        .frame(width: UIScreen.main.bounds.width, height: 300)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                        )
                }
            }
        }
    }
}
