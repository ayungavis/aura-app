//
//  Logo.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 21/04/26.
//

import SwiftUI

struct Logo: View {
    var body: some View {
        CustomText(AppConfig.appName, variant: .custom(family: .serif, weight: .regular, size: 36, style: .headline))
    }
}

#Preview {
    Logo()
}
