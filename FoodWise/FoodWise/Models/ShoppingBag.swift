//
//  ShoppingBag.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 06/03/22.
//

import Foundation

struct ShoppingBag: Codable {
  let ownerId: String
  var lineItems: [LineItem]
  let merchantShopAtId: String?
}
