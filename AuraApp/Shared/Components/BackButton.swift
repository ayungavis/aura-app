//
//  BackButton.swift
//  AuraApp
//
//  A reusable back button with a white circular background and shadow.
//

import SwiftUI

struct BackButton: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black)
                .padding(12)
                .background(
                    Circle()
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 4)
                )
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2).edgesIgnoringSafeArea(.all)
        BackButton()
    }
}
