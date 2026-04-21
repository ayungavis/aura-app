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
                    .font(.footnote)
                    .foregroundColor(.primary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 2) {
                            ForEach(Array(0..<max(0, review.rating ?? 0)), id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .resizable()
                                    .frame(width: 8, height: 8)
                                    .foregroundColor(.yellow)
                            }
                        }

                        Text("\(review.user?.username ?? "Anonymous") • \(formattedDate(review.publishedDate))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(16)
            .frame(width: 220, alignment: .topLeading)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(16)
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
    DetailView.ReviewCard(review: LocationReview(id: 1, title: "Great", text: "Lovely place!", rating: 5, publishedDate: "2024-04-20T10:00:00Z", user: ReviewUser(username: "John", userLocation: nil)))
        .padding()
}
