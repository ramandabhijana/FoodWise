//
//  UINavigationController+.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 05/04/22.
//

import SwiftUI
import UIKit

extension NSNotification.Name {
  static var updateNavigationBarNotification: NSNotification.Name { .init(rawValue: "updateNavigationBarNotification") }
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

extension UINavigationController: UIGestureRecognizerDelegate {
  open override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationBar.tintColor = UIColor.black
    interactivePopGestureRecognizer?.delegate = self
    NotificationCenter.default.addObserver(self, selector: #selector(updateNavigationBar(_:)), name: .updateNavigationBarNotification, object: nil)
  }
  
  
  public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return viewControllers.count > 1
  }
  
  @objc func updateNavigationBar(_ notification: NSNotification) {
    if let info = notification.userInfo {
      let standardColor = info["standardColor"] as! Color
      let scrollEdgeColor = info["scrollEdgeColor"] as! Color
      
      let buttonAppearance = UIBarButtonItemAppearance(style: .plain)
      buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.black]
      UINavigationBar.appearance().tintColor = UIColor.black
      
      let standardAppearance = UINavigationBarAppearance()
      standardAppearance.configureWithTransparentBackground()
      standardAppearance.backgroundColor = UIColor(standardColor)
      standardAppearance.buttonAppearance = buttonAppearance
      
      let scrollEdgeAppearance = UINavigationBarAppearance()
      scrollEdgeAppearance.configureWithTransparentBackground()
      scrollEdgeAppearance.backgroundColor = UIColor(scrollEdgeColor)
      scrollEdgeAppearance.buttonAppearance = buttonAppearance
      
      navigationBar.standardAppearance = standardAppearance
      navigationBar.scrollEdgeAppearance = scrollEdgeAppearance
      navigationBar.compactAppearance = standardAppearance
    } else {
      let appearance = UINavigationBarAppearance()
      let transparentAppearance = UINavigationBarAppearance()
      transparentAppearance.configureWithTransparentBackground()
      navigationBar.standardAppearance = appearance
      navigationBar.scrollEdgeAppearance = transparentAppearance
      navigationBar.compactAppearance = appearance
    }
  }
}
