//
//  HeaderImage.swift
//  AuraApp
//

import SwiftUI

extension DetailView {
    struct HeaderImage: View {
        let photos: [LocationPhoto]
        var onTap: (() -> Void)? = nil
        
        var body: some View {
            ZStack(alignment: .bottom) {
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
                    .containerRelativeFrame(.horizontal)
                    .frame(height: 400)
                    .clipped()
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
    }
}
