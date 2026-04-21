//
//  CustomText.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 21/04/26.
//

import SwiftUI

enum AuraTextVariant {
    case h1
    case h2
    case body
    case caption
    /// Add custom option for edge cases
    case custom(family: AuraFontFamily, weight: AuraFontWeight, size: CGFloat, style: Font.TextStyle)

    var font: Font {
        switch self {
        case .h1:
            return .aura(.serif, weight: .regular, size: 32, relativeTo: .largeTitle)
        case .h2:
            return .aura(.sans, weight: .bold, size: 24, relativeTo: .title)
        case .body:
            return .aura(.sans, weight: .regular, size: 16, relativeTo: .body)
        case .caption:
            return .aura(.sans, weight: .medium, size: 12, relativeTo: .caption)
        case .custom(let family, let weight, let size, let style):
            return .aura(family, weight: weight, size: size, relativeTo: style)
        }
    }
}

struct CustomText: View {
    var text: String
    var variant: AuraTextVariant
    var color: Color

    init(_ text: String, variant: AuraTextVariant = .body, color: Color = .primary) {
        self.text = text
        self.variant = variant
        self.color = color
    }

    var body: some View {
        Text(text)
            .font(variant.font)
            .foregroundColor(color)
    }
}

#Preview {
    VStack {
        CustomText("This is header 1", variant: .h1)
        CustomText("This is header 2", variant: .h2)
        CustomText("This is a body")
        CustomText("This is a caption", variant: .caption)
        CustomText("This is a custom text", variant: .custom(family: .serif, weight: .regular, size: 18, style: .title))
    }
}
