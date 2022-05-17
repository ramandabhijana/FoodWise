//
//  VLineHLine.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 04/04/22.
//

import SwiftUI

// https://stackoverflow.com/a/66863513
struct VLine: Shape {
  func path(in rect: CGRect) -> Path {
    Path { path in
      path.move(to: CGPoint(x: rect.midX, y: rect.minY))
      path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
    }
  }
}

struct HLine: Shape {
  func path(in rect: CGRect) -> Path {
    Path { path in
      path.move(to: CGPoint(x: rect.minX, y: rect.midY))
      path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
    }
  }
}
