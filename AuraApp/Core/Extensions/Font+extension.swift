//
//  Font+extension.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 21/04/26.
//

import SwiftUI

enum AuraFontFamily: String {
    case sans = "InstrumentSans"
    case serif = "InstrumentSerif"
}

enum AuraFontWeight: String {
    case regular = "Regular"
    case medium = "Medium"
    case semiBold = "SemiBold"
    case bold = "Bold"
}

extension Font {
    /// Generates the custom font with Dynamic Type support
    static func aura(
        _ family: AuraFontFamily = .sans,
        weight: AuraFontWeight = .regular,
        size: CGFloat,
        relativeTo textStyle: Font.TextStyle = .body
    ) -> Font {
        // Dynamically creates strings like "InstrumentSans-SemiBold"
        let fontName = "\(family.rawValue)-\(weight.rawValue)"
        return .custom(fontName, size: size, relativeTo: textStyle)
    }
}
