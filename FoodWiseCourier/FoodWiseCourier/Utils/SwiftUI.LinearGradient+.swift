//
//  SwiftUI.LinearGradient+.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 20/11/21.
//

import SwiftUI

extension LinearGradient {
  static let navigationBarBackgroundColor = LinearGradient(
    gradient: Gradient(
      stops: [
        .init(color: .backgroundColor.opacity(0.8), location: 0.2),
        .init(color: .backgroundColor.opacity(0.3), location: 0.8)
        
      ]
    ),
    startPoint: .top,
    endPoint: .bottom
  )
}
