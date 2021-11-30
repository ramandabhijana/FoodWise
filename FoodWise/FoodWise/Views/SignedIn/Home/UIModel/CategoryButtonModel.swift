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
  
  static func == (lhs: CategoryButtonModel, rhs: CategoryButtonModel) -> Bool {
    return lhs.name == rhs.name && lhs.image == rhs.image
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(name)
  }
}

extension CategoryButtonModel {
  static var data: [CategoryButtonModel] {
    [.init(image: .riceIcon, name: "Rice"),
     .init(image: .chickenIcon, name: "Chicken"),
     .init(image: .spinachIcon, name: "Veggie"),
     .init(image: .pizzaIcon, name: "Fast Food"),
     .init(image: .prawnIcon, name: "Seafood"),
     .init(image: .samosaIcon, name: "Snack"),
     .init(image: .cupcakeIcon, name: "Pastry"),
     .init(image: .cupIcon, name: "Beverage")
    ]
  }
}
