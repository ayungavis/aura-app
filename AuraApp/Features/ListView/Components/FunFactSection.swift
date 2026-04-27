//
//  FunFactSection.swift
//  AuraApp
//

import SwiftUI

extension ListView {
    struct FunFactSection: View {
        let fact: String?
        let isLoading: Bool
        @Binding var showFunFactAlert: Bool
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Fun fact")
                        .font(.custom("InstrumentSerif-Regular", size: 24))
                    
                    Button(action: {
                        showFunFactAlert = true
                    }) {
                        Image(systemName: "info.circle")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                if isLoading {
                    VStack(alignment: .leading, spacing: 8) {
                        SkeletonView().frame(height: 12).frame(maxWidth: .infinity)
                        SkeletonView().frame(height: 12).frame(width: 200)
                    }
                } else if let fact = fact {
                    Text(fact)
                        .font(.custom("InstrumentSans-Regular", size: 12))
                        .foregroundColor(.primary)
                        .lineSpacing(4)
                        .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
            .animation(.easeInOut, value: isLoading)
        }
    }
}

#Preview {
    ListView.FunFactSection(fact: "Outdoor activities can boost your mood and reduce stress significantly.", isLoading: false, showFunFactAlert: .constant(false))
}
