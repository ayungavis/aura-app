//
//  TitleSection.swift
//  AuraApp
//

import SwiftUI

extension DetailView {
    struct TitleSection: View {
        let detail: LocationDetail?
        var distance: String? = nil
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                let country = detail?.addressObj?.country ?? ""
                Text(cleanedName(detail?.name ?? "Unknown Place", country: country))
                    .font(.custom("InstrumentSerif-Regular", size: 36))
                    .foregroundColor(.primary)

                if let ratingStr = detail?.rating, let numReviews = detail?.numReviews {
                    HStack(spacing: 4) {
                        Text(ratingStr)
                            .font(.custom("InstrumentSans-Medium", size: 14))
                            .fontWeight(.medium)
                        
                        HStack(spacing: 2) {
                            let ratingDouble = Double(ratingStr) ?? 0.0
                            ForEach(0..<5) { index in
                                let diff = ratingDouble - Double(index)
                                if diff >= 0.75 {
                                    Image(systemName: "star.fill")
                                } else if diff >= 0.25 {
                                    Image(systemName: "star.leadinghalf.filled")
                                } else {
                                    Image(systemName: "star")
                                }
                            }
                        }
                        .foregroundColor(.black)
                        .font(.caption2)
                        
                        Text("(\(numReviews))")
                            .font(.custom("InstrumentSans-Medium", size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    if let subcategories = detail?.subcategory, !subcategories.isEmpty {
                        Text(subcategories.compactMap { $0.localizedName }.joined(separator: ", "))
                    } else if let categoryName = detail?.category?.localizedName {
                        Text(categoryName)
                    }
                    
                    if let distString = distance, let distDouble = Double(distString) {
                        let mins = Int(ceil(distDouble * 5))
                        let timeDisplay = mins > 0 ? "\(mins) mins" : "1 min"
                        Text("• \(String(format: "%.1f", distDouble)) km • \(timeDisplay)")
                    } else {
                        Text("• 10 mins")
                    }
                }
                .font(.custom("InstrumentSans-Medium", size: 14))
                .foregroundColor(.secondary)
            }
            .padding(.horizontal)
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
