//
//  Collection+.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 11/04/22.
//

import Foundation

extension Collection {
  subscript (safe index: Index) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }
}
