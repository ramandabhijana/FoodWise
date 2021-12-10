//
//  CategoryButtonModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 03/11/21.
//

import SwiftUI

struct CategoryButtonModel: Hashable, Identifiable {
  var id: UUID = .init()
  let image: Image
  let name: String
  let categories: FoodCategories
  
  static func == (lhs: CategoryButtonModel, rhs: CategoryButtonModel) -> Bool {
    return lhs.name == rhs.name && lhs.image == rhs.image
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(name)
  }
}

extension CategoryButtonModel {
  static let data: [CategoryButtonModel] = [
    .init(image: .riceIcon, name: "Rice", categories: .rice),
    .init(image: .chickenIcon, name: "Chicken", categories: .chickenDuck),
    .init(image: .spinachIcon, name: "Veggie", categories: .veggie),
    .init(image: .pizzaIcon, name: "Fast Food", categories: .fastFood),
    .init(image: .prawnIcon, name: "Seafood", categories: .seafood),
    .init(image: .samosaIcon, name: "Snack", categories: .snack),
    .init(image: .cupcakeIcon, name: "Pastry", categories: .pastry),
    .init(image: .cupIcon, name: "Beverage", categories: .beverage)
  ]
}
