//
//  SectionHeader.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 22/04/26.
//

import SwiftUI

struct SectionHeader: View {
  let title: String
  let rightContent: AnyView?

  init(title: String, rightContent: AnyView? = nil) {
    self.title = title
    self.rightContent = rightContent
  }

  var body: some View {
    Layout(direction: .horizontal, justify: .spaceBetween, width: .fill) {
      CustomText(title, variant: .custom(family: .serif, weight: .regular, size: 20, style: .title))

      if let rightContent = rightContent {
        rightContent
      }
    }
  }
}

#Preview {
  SectionHeader(title: "Section title")
}
