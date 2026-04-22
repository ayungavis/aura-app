//
//  PhotosSection.swift
//  AuraApp
//

import SwiftUI

extension DetailView {
    struct PhotosSection: View {
        let photos: [LocationPhoto]
        
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Photos")
                    .font(.custom("InstrumentSerif-Regular", size: 28))

                if photos.isEmpty {
                    Text("No photos available")
                        .font(.custom("InstrumentSans-Medium", size: 14))
                        .foregroundColor(.secondary)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
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
                                    .frame(width: 140, height: 140)
                                    .clipped()
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
