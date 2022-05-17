//
//  DestinationAnnotationView.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 07/04/22.
//

import SwiftUI

struct DestinationAnnotationView: View {
  var body: some View {
    GeometryReader { proxy in
      FoodWiseMapPin()
        .stroke(style: StrokeStyle(
          lineWidth: proxy.size.width * 0.07,
          lineCap: .round)
        )
        .fill(Color.accentColor)
        .background(
          FoodWiseMapPin().fill(Color.primaryColor)
        )
        .overlay(circle(withSize: proxy.size.width))
    }
    .frame(width: 30, height: 60)
  }
  
  private func circle(withSize size: CGFloat) -> some View {
    let width = size * 0.7
    return ZStack {
      Circle()
        .fill(Color.backgroundColor)
      Circle()
        .strokeBorder(Color.accentColor, lineWidth: width * 0.05)
    }
    .frame(width: width, height: width)
    .frame(width: width, height: width)
  }
}
