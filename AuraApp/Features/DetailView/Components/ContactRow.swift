//
//  ContactRow.swift
//  AuraApp
//

import SwiftUI

extension DetailView {
    struct ContactRow: View {
        let title: String
        let value: String

        var body: some View {
            HStack(alignment: .top) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                Text(value)
                    .font(.subheadline)
                    .multilineTextAlignment(.trailing)
            }
        }
    }
}
