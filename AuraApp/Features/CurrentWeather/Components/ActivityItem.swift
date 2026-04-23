//
//  ActivityItem.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 22/04/26.
//

import SwiftUI

struct ActivityItem: View {
  let activity: any CardItem

  var body: some View {
    ZStack {
      Image(activity.imageName)
        .resizable()
        .scaledToFill()
        .colorEffect(ShaderLibrary.dither())

      Layout(direction: .vertical, justify: .end, height: .fill) {
        RoundedRectangle(cornerRadius: 0)
          .fill(
            LinearGradient(
              colors: [.white, .white.opacity(0)],
              startPoint: .bottom,
              endPoint: .top
            )
          ).frame(height: .infinity)

        Layout(
          direction: .horizontal,
          justify: .spaceBetween,
          align: .center,
          horizontalPadding: 10,
          width: .fill,
          height: .fixed(32)
        ) {
          CustomText(activity.title, variant: .caption)

          Spacer()

          CustomText(
            activity.subtitle,
            variant: .custom(family: .serif, weight: .regular, size: 10, style: .caption)
          )
        }
        .background(.white)
      }
    }
    .border(.border, width: 0.2)
    .frame(width: 141, height: 141)
  }
}

#Preview {
  ActivityItem(activity: RECOMMENDED_ACTIVITIES[0])
}
