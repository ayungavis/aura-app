//
//  SkeletonView.swift
//  AuraApp
//
//  A reusable skeleton loading component with a pulsing animation.
//

import SwiftUI

struct SkeletonView: View {
    @State private var isAnimating = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color(UIColor.systemGray5))
            .opacity(isAnimating ? 0.5 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
    }
}

struct SkeletonRow: View {
    var body: some View {
        HStack(spacing: 12) {
            SkeletonView()
                .frame(width: 80, height: 80)
            
            VStack(alignment: .leading, spacing: 8) {
                SkeletonView()
                    .frame(height: 20)
                    .frame(maxWidth: .infinity)
                
                SkeletonView()
                    .frame(height: 14)
                    .frame(width: 150)
                
                SkeletonView()
                    .frame(height: 14)
                    .frame(width: 100)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        SkeletonView().frame(height: 100)
        SkeletonRow()
        SkeletonRow()
    }
    .padding()
}
