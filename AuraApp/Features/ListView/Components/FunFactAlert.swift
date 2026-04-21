//
//  FunFactAlert.swift
//  AuraApp
//

import SwiftUI

extension ListView {
    struct FunFactAlert: View {
        @Binding var showFunFactAlert: Bool
        
        var body: some View {
            ZStack {
                if showFunFactAlert {
                    // Dimmed background
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                        .transition(.opacity)
                        .onTapGesture {
                            showFunFactAlert = false
                        }
                    
                    // Alert Box
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Fun Fact Notice")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("This fun fact is randomly generated from publicly available internet sources and may vary in accuracy.")
                                .font(.body)
                            
                            Text("Enjoy it as light, motivational content.")
                                .font(.body)
                        }
                        .foregroundColor(.secondary)
                        
                        Button(action: {
                            showFunFactAlert = false
                        }) {
                            Text("Got it 👌")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(25)
                                .foregroundColor(.primary)
                        }
                        .padding(.top, 8)
                    }
                    .padding(30)
                    .background(
                        RoundedRectangle(cornerRadius: 32)
                            .fill(Color.white)
                    )
                    .padding(.horizontal, 30)
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showFunFactAlert)
        }
    }
}

#Preview {
    ListView.FunFactAlert(showFunFactAlert: .constant(true))
}
