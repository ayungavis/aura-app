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
                    .font(.headline)

                VStack(spacing: 12) {
                    if let phone = detail?.phone, !phone.isEmpty {
                        ContactRow(title: "Phone", value: phone)
                    }
                    if let website = detail?.website, !website.isEmpty {
                        ContactRow(title: "Website", value: website)
                    }

                    if let addr = detail?.addressObj {
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
            }
            .padding(.horizontal)
        }
    }
}
