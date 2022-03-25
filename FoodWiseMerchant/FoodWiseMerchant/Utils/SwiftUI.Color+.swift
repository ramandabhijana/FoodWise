//
//  SwiftUI.Color+.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 30/10/21.
//

import SwiftUI

extension Color {
  public static var primaryColor: Color { .init("PrimaryColor") }
  public static var backgroundColor: Color { .init("BackgroundColor") }
  public static var errorColor: Color { .init("ErrorColor") }
  public static var secondaryColor: Color { .init("SecondaryColor") }
}

extension UIColor {
  public static var primaryColor: UIColor { .init(named: "PrimaryColor")! }
  public static var backgroundColor: UIColor { .init(named: "BackgroundColor")! }
  public static var errorColor: UIColor { .init(named: "ErrorColor")! }
  public static var secondaryColor: UIColor { .init(named: "SecondaryColor")! }
  public static var accentColor: UIColor { .init(named: "AccentColor")! }
}
