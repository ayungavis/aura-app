//
//  HeaderImage.swift
//  AuraApp
//

import SwiftUI

extension DetailView {
    struct HeaderImage: View {
        let photos: [LocationPhoto]
        let initialImageUrl: String?
        let locationId: String
        let animation: Namespace.ID
        var onTap: (() -> Void)?

        init(
            photos: [LocationPhoto],
            initialImageUrl: String?,
            locationId: String,
            animation: Namespace.ID,
            onTap: (() -> Void)? = nil
        ) {
            self.photos = photos
            self.initialImageUrl = initialImageUrl
            self.locationId = locationId
            self.animation = animation
            self.onTap = onTap
        }
        
        var body: some View {
            ZStack(alignment: .bottom) {
                if let firstPhoto = photos.first,
                   let urlString = firstPhoto.images?.large?.url,
                   let url = URL(string: urlString) {
                    imageContent(url: url)
                } else if let initialImageUrl = initialImageUrl,
                          let url = URL(string: initialImageUrl) {
                    imageContent(url: url)
                } else {
                    Rectangle()
                        .fill(Color(UIColor.systemGray5))
                        .containerRelativeFrame(.horizontal)
                        .frame(height: 400)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                        )
                }
                
                Image("effect-dithered")
                    .resizable()
                    .scaledToFill()
                    .containerRelativeFrame(.horizontal)
                    .frame(height: 400)
                    .clipped()
                
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .white]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 120)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onTap?()
            }
        }
        private func imageContent(url: URL) -> some View {
            CachedAsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Rectangle()
                    .fill(Color(UIColor.systemGray5))
                    .overlay(ProgressView())
            }
            .containerRelativeFrame(.horizontal)
            .frame(height: 400)
            .clipped()
        }
    }
}
