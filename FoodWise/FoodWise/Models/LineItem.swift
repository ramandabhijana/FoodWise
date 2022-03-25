//
//  LineItem.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 07/03/22.
//

import Foundation

struct LineItem: Identifiable, Codable {
  let id: String
  let foodId: String
  var quantity: Int
  var price: Double? = nil
  var food: Food? = nil
  
  var asObject: [String: Any] {
    ["id": id,
     "foodId": foodId,
     "quantity": quantity,
     "price": price as Any,
     "food": food as Any]
  }
}


