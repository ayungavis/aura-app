//
//  TitleSection.swift
//  AuraApp
//

import SwiftUI

extension DetailView {
    struct TitleSection: View {
        let detail: LocationDetail?
        
        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(detail?.name ?? "Unknown Place")
                    .font(.title2)
                    .fontWeight(.bold)

                if let address = detail?.addressObj?.addressString {
                    Text(address)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                if let subcategories = detail?.subcategory, !subcategories.isEmpty {
                    Text(subcategories.compactMap { $0.localizedName }.joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else if let categoryName = detail?.category?.localizedName {
                    Text(categoryName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                if let rating = detail?.rating, let numReviews = detail?.numReviews {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text(rating)
                            .font(.subheadline)
                        Text("(\(numReviews) reviews)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}
