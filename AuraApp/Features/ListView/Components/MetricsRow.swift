//
//  MetricsRow.swift
//  AuraApp
//

import SwiftUI

extension ListView {
    struct MetricsRow: View {
        var body: some View {
            VStack(spacing: 4) {
                Text("6 km / 60 mins")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    Label("8 km/h", systemImage: "speedometer")
                    Label("30°", systemImage: "sun.max")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    ListView.MetricsRow()
}
