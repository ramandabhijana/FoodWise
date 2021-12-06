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
  
  func setupFoodWiseNavigationBarAppearance() {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithTransparentBackground()
    appearance.backgroundColor = UIColor(named: "PrimaryColor")
    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
//    UINavigationBar.appearance().tintColor = .black
    
  }
}
