//
//  ReviewCard.swift
//  AuraApp
//

import SwiftUI

extension DetailView {
    struct ReviewCard: View {
        let review: LocationReview

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text(review.text ?? "No review text")
                    .font(.custom("InstrumentSans-Regular", size: 12))
                    .foregroundColor(.primary)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    if let avatarUrl = review.user?.avatar?.thumbnail,
                       let url = URL(string: avatarUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Rectangle()
                                .fill(Color.black)
                                .overlay(ProgressView().tint(.white).scaleEffect(0.5))
                        }
                        .frame(width: 32, height: 32)
                        .clipped()
                    } else {
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16))
                            )
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        StarRatingView(rating: Double(review.rating ?? 0), starSize: 8)

                        Text("\(review.user?.username ?? "Anonymous") • \(formattedDate(review.publishedDate))")
                            .font(.custom("InstrumentSans-Regular", size: 10))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(width: 210, alignment: .topLeading)
        }

        private func formattedDate(_ dateString: String?) -> String {
            guard let dateString = dateString else { return "" }
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = isoFormatter.date(from: dateString) {
                let formatter = RelativeDateTimeFormatter()
                formatter.unitsStyle = .full
                return formatter.localizedString(for: date, relativeTo: Date())
            }
            isoFormatter.formatOptions = [.withInternetDateTime]
            if let date = isoFormatter.date(from: dateString) {
                let formatter = RelativeDateTimeFormatter()
                formatter.unitsStyle = .full
                return formatter.localizedString(for: date, relativeTo: Date())
            }
            return dateString
        }
    }
}

#Preview {
    DetailView.ReviewCard(review: LocationReview(id: 1, title: "Great", text: "Lovely place!", rating: 5, publishedDate: "2024-04-20T10:00:00Z", user: ReviewUser(username: "John", userLocation: nil, avatar: nil)))
        .padding()
}
