//
//  ReviewsSection.swift
//  AuraApp
//

import SwiftUI

extension DetailView {
    struct ReviewsSection: View {
        let reviews: [LocationReview]
        var webUrl: String? = nil
        
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Reviews")
                        .font(.custom("InstrumentSerif-Regular", size: 28))
                    
                    Spacer()
                    
                    if let urlString = webUrl, let url = URL(string: urlString) {
                        Link(destination: url) {
                            HStack(spacing: 4) {
                                Text("Open Tripadvisor")
                                Image(systemName: "arrow.up.right.square")
                            }
                            .font(.custom("InstrumentSans-Medium", size: 12))
                            .foregroundColor(.blue)
                        }
                    }
                }

                if reviews.isEmpty {
                    Text("No reviews available")
                        .font(.custom("InstrumentSans-Medium", size: 14))
                        .foregroundColor(.secondary)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
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
