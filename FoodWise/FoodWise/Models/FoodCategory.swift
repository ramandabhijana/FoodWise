//
//  FoodCategory.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 06/12/21.
//

import Foundation

struct FoodCategory: Identifiable, Codable {
  var id: String
  let name: String
  
  private static var idCount = 1
  
  private init(name: String) {
    self.id = "\(Self.idCount)"
    self.name = name
    Self.idCount += 1
  }
  
  var asObject: [String: Any] { ["id": id, "name": name] }
  
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

enum FoodCategories: Int {
  case rice
  case noodle
  case chickenDuck
  case veggie
  case fruit
  case fastFood
  case seafood
  case snack
  case pastry
  case sweets
  case beverage
  case pork
  case beef
  case basoSoto
  case satay
  case japanese
  case chinese
  case western
  case middleEastern
  case thai
  case indian
  
  var category: FoodCategory { .categoriesData[rawValue] }
  
}

