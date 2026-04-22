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
                    .font(.custom("InstrumentSans-Medium", size: 14))
                    .foregroundColor(.secondary)

                Spacer()

                Text(value)
                    .font(.custom("InstrumentSans-Medium", size: 14))
                    .foregroundColor(title == "Address" ? .primary : .blue)
                    .multilineTextAlignment(.trailing)
            }
        }
    }
}
