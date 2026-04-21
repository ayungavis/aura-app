//
//  ReviewsSection.swift
//  AuraApp
//

import SwiftUI

extension DetailView {
    struct ReviewsSection: View {
        let reviews: [LocationReview]
        
        var body: some View {
            VStack(alignment: .leading) {
                Text("Ratings and Reviews")
                    .font(.headline)

                if reviews.isEmpty {
                    Text("No reviews available")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(reviews) { review in
                                ReviewCard(review: review)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}
