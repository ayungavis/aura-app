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
            return .aura(.sans, weight: .regular, size: 14, relativeTo: .body)
        case .caption:
            return .aura(.sans, weight: .medium, size: 12, relativeTo: .caption)
        case .custom(let family, let weight, let size, let style):
            return .aura(family, weight: weight, size: size, relativeTo: style)
        }
    }

    var fontSize: CGFloat {
        switch self {
        case .h1: return 32
        case .h2: return 24
        case .body: return 14
        case .caption: return 12
        case .custom(_, _, let size, _): return size
        }
    }

    var defaultLineHeight: CGFloat {
        switch self {
        case .h1: return 0
        case .h2: return 0
        case .body: return 18
        case .caption: return 16
        case .custom(_, _, let size, _): return size * 1.2 // safe default: 20% more than font size
        }
    }
}

struct CustomText: View {
    var text: String
    var variant: AuraTextVariant
    var color: Color
    var lineHeight: CGFloat?

    init(_ text: String, variant: AuraTextVariant = .body, color: Color = .primary, lineHeight: CGFloat? = nil) {
        self.text = text
        self.variant = variant
        self.color = color
        self.lineHeight = lineHeight
    }

    private var effectiveLineHeight: CGFloat {
        lineHeight ?? variant.defaultLineHeight
    }

    private var lineSpacing: CGFloat {
        let spacing = effectiveLineHeight - variant.fontSize
        return max(spacing, 0)
    }

    private var verticalPadding: CGFloat {
        lineSpacing / 2
    }

    var body: some View {
        Text(text)
            .font(variant.font)
            .foregroundColor(color)
            .lineSpacing(lineSpacing)
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
