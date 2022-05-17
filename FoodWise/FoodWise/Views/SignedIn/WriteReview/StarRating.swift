//
//  StarRating.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 20/04/22.
//

import SwiftUI

struct RatingStar: View {
  let size: CGFloat
  var fill: Fill
  
  var body: some View {
    Star(smoothness: 0.4)
      .fill(Color(uiColor: .darkGray).opacity(fill == .none ? 0.25 : 1.0))
      .frame(width: size, height: size)
      .overlay(alignment: .center) {
        Star(smoothness: 0.4, corners: 3)
          .fill(fill == .half || fill == .full ? Color.primaryColor : Color.clear)
          .frame(width: size * 0.73, height: size * 0.73)
          .rotation3DEffect(.degrees(180), axis: (x: 0, y:1, z: 0))
      }
      .overlay(alignment: .center) {
        Star(smoothness: 0.4, corners: 3)
          .fill(fill == .half || fill == .none ? Color.clear : Color.primaryColor)
          .frame(width: size * 0.73, height: size * 0.73)
      }
      .animation(.default, value: fill)
  }
  
  enum Fill {
    case half, full, none
  }
}
