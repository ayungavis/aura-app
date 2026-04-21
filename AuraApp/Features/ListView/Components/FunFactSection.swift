//
//  FunFactSection.swift
//  AuraApp
//

import SwiftUI

extension ListView {
    struct FunFactSection: View {
        let category: String
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
                
                Text(funFactForCategory(category))
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineSpacing(4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
        }
        
        private func funFactForCategory(_ category: String) -> String {
            switch category.lowercased() {
            case "running":
                return "Running can boost your mood fast. Your body releases endorphins that help you feel good."
            case "biking":
                return "Cycling for 30 minutes can burn up to 300 calories and improves heart health."
            default:
                return "Outdoor activities can boost your mood and reduce stress significantly."
            }
        }
    }
}

#Preview {
    ListView.FunFactSection(category: "Running", showFunFactAlert: .constant(false))
}
