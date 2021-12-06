//
//  FoodCategory.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 04/12/21.
//

import Foundation

struct FoodCategory: Identifiable, Codable {
  var id: UUID = .init()
  let name: String
  
  static var categoriesData: [FoodCategory] = [
    .init(name: "Rice"),
    .init(name: "Noodle"),
    .init(name: "Chicken & Duck"),
    .init(name: "Veggie"),
    .init(name: "Fruit"),
    .init(name: "Fast Food"),
    .init(name: "Seafood"),
    .init(name: "Snack"),
    .init(name: "Pastry"),
    .init(name: "Sweets"),
    .init(name: "Beverage"),
    .init(name: "Pork"),
    .init(name: "Beef"),
    .init(name: "Baso & Soto"),
    .init(name: "Satay"),
    .init(name: "Japanese"),
    .init(name: "Chinese"),
    .init(name: "Western"),
    .init(name: "Middle Eastern"),
    .init(name: "Thai"),
    .init(name: "Indian")
  ]
}
