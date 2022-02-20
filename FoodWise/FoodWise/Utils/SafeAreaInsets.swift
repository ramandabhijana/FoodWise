//
//  SafeAreaInsets.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 06/02/22.
//

import SwiftUI

extension UIApplication {
  var keyWindow: UIWindow? {
    connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap(\.windows)
      .first(where: \.isKeyWindow)
  }
}

private struct SafeAreaInsetsKey: EnvironmentKey {
  static var defaultValue: EdgeInsets {
    UIApplication.shared.keyWindow?.safeAreaInsets.swiftUiInsets ?? EdgeInsets()
  }
}

extension EnvironmentValues {
  var safeAreaInsets: EdgeInsets {
    self[SafeAreaInsetsKey.self]
  }
}

private extension UIEdgeInsets {
  var swiftUiInsets: EdgeInsets {
    EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
  }
}
