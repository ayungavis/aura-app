//
//  PlaceRow.swift
//  AuraApp
//

import SwiftUI

extension ListView {
    struct PlaceRow: View {
        let location: LocationItem
        let animation: Namespace.ID
        
        var body: some View {
            HStack(spacing: 16) {
                // Square thumbnail
                Group {
                    if let imageUrl = location.imageUrl, let url = URL(string: imageUrl) {
                        CachedAsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            placeholderImage
                        }
                    } else {
                        placeholderImage
                    }
                }
                .frame(width: 80, height: 80)
                .clipped()
                .matchedTransitionSource(id: location.locationId, in: animation)
                
                VStack(alignment: .leading, spacing: 4) {
                    let country = location.addressObj?.country ?? ""
                    let cityName = location.addressObj?.city ?? ""
                    
                    Text(cleanedName(location.name, country: country))
                        .font(.custom("InstrumentSans-Medium", size: 12))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    // Address Row
                    let addressParts = [cityName, country].filter { !$0.isEmpty }
                    if !addressParts.isEmpty {
                        Text(addressParts.joined(separator: ", "))
                            .font(.custom("InstrumentSans-Medium", size: 10))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    HStack {
                        if let distString = location.distance, let distDouble = Double(distString) {
                             let mins = Int(ceil(distDouble * 5))
                             let timeDisplay = mins > 0 ? "\(mins) mins" : "1 min"
                             
                             Text("\(String(format: "%.1f", distDouble)) km • \(timeDisplay)")
                                .font(.custom("InstrumentSans-Medium", size: 10))
                                .foregroundColor(.secondary)
                        } else {
                             Text("• 10 mins")
                                .font(.custom("InstrumentSans-Medium", size: 10))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        
        private var placeholderImage: some View {
            Rectangle()
                .fill(Color(UIColor.systemGray5))
                .overlay(
                    Image(systemName: "photo")
                        .foregroundColor(.secondary)
                )
        }
        
        private func cleanedName(_ original: String, country: String) -> String {
            guard !country.isEmpty else { return original }
            
            var result = original.replacingOccurrences(of: country, with: "", options: [.caseInsensitive])
            
            let cleanupPattern = "^[-,\\s]+|[-,\\s]+$|([-,\\s]){2,}"
            if let regex = try? NSRegularExpression(pattern: cleanupPattern) {
                let range = NSRange(location: 0, length: result.utf16.count)
                result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "$1")
            }
            
            result = result.trimmingCharacters(in: .whitespacesAndNewlines)
            return result.isEmpty ? original : result
        }
    }
}

#Preview {
    @Previewable @Namespace var anim
    ListView.PlaceRow(
        location: LocationItem(locationId: "1", name: "Sample Place", addressObj: AddressObj(street1: nil, street2: nil, city: "Paris", state: nil, country: "France", postalcode: nil, addressString: nil), distance: "5.5", imageUrl: nil),
        animation: anim
    )
    .padding()
}
