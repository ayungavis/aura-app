//
//  PhotoDetailView.swift
//  AuraApp
//

import SwiftUI

struct PhotoDetailView: View {
    let photos: [LocationPhoto]
    @Binding var currentIndex: Int
    var onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            ZStack {
                Text("\(currentIndex + 1) of \(photos.count)")
                    .font(.custom("InstrumentSerif-Regular", size: 24))
                    .foregroundColor(.black)
                
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.black)
                            .padding(12)
                            .background(Color.black.opacity(0.05))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            Spacer()
            
            // Image Slider
            TabView(selection: $currentIndex) {
                ForEach(0..<photos.count, id: \.self) { index in
                    if let urlString = photos[index].images?.original?.url ?? photos[index].images?.large?.url,
                       let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } placeholder: {
                            ProgressView()
                        }
                        .tag(index)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            Spacer()
            
            // Bottom Info
            if currentIndex < photos.count {
                let photo = photos[currentIndex]
                VStack(alignment: .leading, spacing: 12) {
                    if let caption = photo.caption, !caption.isEmpty {
                        Text(caption)
                            .font(.custom("InstrumentSans-Medium", size: 14))
                            .foregroundColor(.black)
                    }
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(photo.user?.username ?? photo.source?.name ?? "Aura Contributor")
                                .font(.custom("InstrumentSans-SemiBold", size: 14))
                            Text(formattedDate(photo.publishedDate))
                                .font(.custom("InstrumentSans-Regular", size: 12))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Text("From")
                                .font(.custom("InstrumentSans-Regular", size: 12))
                                .foregroundColor(.secondary)
                            Image("logo-tripadvisor")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 14)
                        }
                    }
                }
                .padding()
                .background(Color.white)
            }
        }
        .background(Color.white)
    }

    private func formattedDate(_ dateString: String?) -> String {
        guard let dateString = dateString else { return "Unknown Date" }
        
        let isoFormatter = ISO8601DateFormatter()
        
        // Try with fractional seconds (e.g., 2018-10-02T03:21:50.892Z)
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: dateString) {
            return formatDate(date)
        }
        
        // Try without fractional seconds (e.g., 2018-10-02T03:21:50Z)
        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = isoFormatter.date(from: dateString) {
            return formatDate(date)
        }
        
        // Fallback for other common ISO formats using DateFormatter
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .iso8601)
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(secondsFromGMT: 0)
        
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX",
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd'T'HH:mm:ssZ"
        ]
        
        for format in formats {
            df.dateFormat = format
            if let date = df.date(from: dateString) {
                return formatDate(date)
            }
        }
        
        return dateString
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
