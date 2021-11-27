//
//  Double+.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 15/11/21.
//

import Foundation

extension Double {
  func asIndonesianCurrencyString() -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale(identifier: "id_ID")
    return formatter.string(from: self as NSNumber)!
  }
}
