//
//  PhotoListView.swift
//  AuraApp
//

import SwiftUI

struct PhotoListView: View {
    let photos: [LocationPhoto]
    let locationName: String?
    var onPhotoTap: (Int) -> Void
    var onBack: () -> Void
    
    // Split photos into two columns for masonry layout
    private var leftColumnPhotos: [(index: Int, photo: LocationPhoto)] {
        photos.enumerated().filter { $0.offset % 2 == 0 }.map { (index: $0.offset, photo: $0.element) }
    }
    
    private var rightColumnPhotos: [(index: Int, photo: LocationPhoto)] {
        photos.enumerated().filter { $0.offset % 2 != 0 }.map { (index: $0.offset, photo: $0.element) }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Title Header
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Photos from Tripadvisor, Unsplash, and Others")
                                .font(.custom("InstrumentSerif-Regular", size: 32))
                                .lineLimit(nil)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: geometry.size.width - 32, alignment: .leading)
                            
                            Text("\(locationName ?? "Location") • \(photos.count) photos")
                                .font(.custom("InstrumentSans-Regular", size: 14))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 80)
                        .padding(.horizontal)
                        
                        // Masonry Grid
                        HStack(alignment: .top, spacing: 12) {
                            let columnWidth = (geometry.size.width - 44) / 2 // (Total - padding - spacing) / 2
                            
                            VStack(spacing: 12) {
                                ForEach(leftColumnPhotos, id: \.index) { item in
                                    PhotoCard(width: columnWidth, index: item.index, photo: item.photo, onPhotoTap: onPhotoTap)
                                }
                            }
                            
                            VStack(spacing: 12) {
                                ForEach(rightColumnPhotos, id: \.index) { item in
                                    PhotoCard(width: columnWidth, index: item.index, photo: item.photo, onPhotoTap: onPhotoTap)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                }
                .frame(width: geometry.size.width)
                
                // Sticky Back Button
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black)
                        .padding(12)
                        .background(Color.white.opacity(0.9))
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                .padding(.leading, 16)
                .padding(.top, 16)
            }
        }
        .background(Color.white)
        .ignoresSafeArea(.keyboard)
    }
}

struct PhotoCard: View {
    let width: CGFloat
    let index: Int
    let photo: LocationPhoto
    let onPhotoTap: (Int) -> Void
    
    var body: some View {
        if let urlString = photo.images?.large?.url ?? photo.images?.medium?.url,
           let url = URL(string: urlString) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .overlay(ProgressView())
            }
            .frame(width: width, height: index % 3 == 0 ? 240 : 160)
            .clipped()
            .contentShape(Rectangle())
            .onTapGesture {
                onPhotoTap(index)
            }
        }
    }
}
