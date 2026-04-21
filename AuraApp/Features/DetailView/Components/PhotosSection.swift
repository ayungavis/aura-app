//
//  PhotosSection.swift
//  AuraApp
//

import SwiftUI

extension DetailView {
    struct PhotosSection: View {
        let photos: [LocationPhoto]
        
        var body: some View {
            VStack(alignment: .leading) {
                Text("Photos")
                    .font(.headline)

                if photos.isEmpty {
                    Text("No photos available")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(photos) { photo in
                                if let urlString = photo.images?.large?.url,
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
                                    .frame(width: 160, height: 120)
                                    .clipped()
                                    .cornerRadius(10)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}
