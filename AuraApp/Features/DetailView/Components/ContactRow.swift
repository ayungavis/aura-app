//
//  ContactRow.swift
//  AuraApp
//

import SwiftUI

extension DetailView {
    struct ContactRow: View {
        let title: String
        let value: String
        var url: URL? = nil

        var body: some View {
            HStack(alignment: .top) {
                Text(title)
                    .font(.custom("InstrumentSans-Medium", size: 14))
                    .foregroundColor(.secondary)

                Spacer()

                if let url = url {
                    Link(destination: url) {
                        Text(value)
                            .font(.custom("InstrumentSans-Medium", size: 14))
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.trailing)
                    }
                } else {
                    Text(value)
                        .font(.custom("InstrumentSans-Medium", size: 14))
                        .foregroundColor(title == "Address" || title == "Hours" ? .primary : .blue)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
    }
}
