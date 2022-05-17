//
//  OriginAnnotationView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 15/04/22.
//

import SwiftUI

struct OriginAnnotationView: View {
  var body: some View {
    GeometryReader { proxy in
      ZStack {
        Circle()
          .strokeBorder(Color.accentColor, lineWidth: proxy.size.width * 0.25)
        Circle()
          .strokeBorder(Color.primaryColor, lineWidth: proxy.size.width * 0.2)
        Circle()
          .strokeBorder(Color.accentColor, lineWidth: proxy.size.width * 0.06)
      }
    }
    .frame(width: 30, height: 30)
  }
}
