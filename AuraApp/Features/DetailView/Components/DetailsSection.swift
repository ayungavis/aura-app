//
//  DetailsSection.swift
//  AuraApp
//

import SwiftUI

extension DetailView {
    struct DetailsSection: View {
        let detail: LocationDetail?
        
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Details")
                    .font(.custom("InstrumentSerif-Regular", size: 28))

                VStack(spacing: 12) {
                    if let phone = detail?.phone, !phone.isEmpty {
                        let cleanPhone = phone.filter { "0123456789+".contains($0) }
                        ContactRow(title: "Phone", value: phone, url: URL(string: "tel://\(cleanPhone)"))
                    }
                    if let website = detail?.website, !website.isEmpty {
                        let cleanWebsite = website
                            .replacingOccurrences(of: "https://", with: "")
                            .replacingOccurrences(of: "http://", with: "")
                        ContactRow(
                            title: "Website",
                            value: cleanWebsite,
                            url: URL(string: website),
                            icon: "arrow.up.right.square"
                        )
                    }
                    if let email = detail?.email, !email.isEmpty {
                        ContactRow(title: "Email", value: email, url: URL(string: "mailto:\(email)"))
                    }

                    if let addr = detail?.addressObj {
                        if let addressString = addr.addressString, !addressString.isEmpty {
                            ContactRow(title: "Address", value: addressString)
                        } else {
                            let addressParts = [
                                addr.street1,
                                addr.city,
                                addr.state,
                                addr.country
                            ].compactMap { $0 }

                            if !addressParts.isEmpty {
                                ContactRow(
                                    title: "Address",
                                    value: addressParts.joined(separator: "\n")
                                )
                            }
                        }
                    }

                    if let hours = detail?.hours?.weekdayText, !hours.isEmpty {
                        ContactRow(title: "Hours", value: hours.joined(separator: "\n"))
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}
