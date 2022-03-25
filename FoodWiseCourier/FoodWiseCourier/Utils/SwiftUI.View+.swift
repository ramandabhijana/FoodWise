//
//  SwiftUI.View+.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 08/11/21.
//

import SwiftUI

// https://www.avanderlee.com/swiftui/conditional-view-modifier/
extension View {
  /// Applies the given transform if the given condition evaluates to `true`.
  /// - Parameters:
  ///   - condition: The condition to evaluate.
  ///   - transform: The transform to apply to the source `View`.
  /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
  @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
    if condition {
      transform(self)
    } else {
      self
    }
  }
}

extension View {
  func setNavigationBarColor(withStandardColor standardColor: Color, andScrollEdgeColor scrollEdgeColor: Color) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
      NotificationCenter.default.post(
        name: .updateNavigationBarNotification,
        object: nil,
        userInfo: ["standardColor": standardColor, "scrollEdgeColor": scrollEdgeColor])
    }
  }
  
  func resetNavigationBar() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
      NotificationCenter.default.post(
        name: .updateNavigationBarNotification,
        object: nil)
    }
  }
}
