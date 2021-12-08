//
//  FavoriteFoodList.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 07/12/21.
//

import Foundation

struct FavoriteFoodList: Identifiable, Codable {
  var id: String { customerId }
  let customerId: String
  var foodIds: [String]
}
