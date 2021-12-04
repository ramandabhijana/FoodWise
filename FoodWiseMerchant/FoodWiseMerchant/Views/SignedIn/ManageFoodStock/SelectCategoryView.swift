//
//  SelectCategoryView.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 04/12/21.
//

import SwiftUI

struct SelectCategoryView: View {
  var body: some View {
    Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
  }
}

struct SelectCategoryView_Previews: PreviewProvider {
  static var previews: some View {
    SelectCategoryView()
  }
}

struct FoodCategory: Identifiable {
  let id: UUID = .init()
  let name: String
}

let categories: [FoodCategory] = [
  .init(name: "Rice"),
  .init(name: "Noodle"),
  .init(name: "Baso & Soto"),
  .init(name: "Chicken"),
  .init(name: "Veggie"),
  .init(name: "Fast Food"),
  .init(name: "Seafood"),
  .init(name: "Snack"),
  .init(name: "Pastry"),
  .init(name: "Beverage"),
  .init(name: "Pork"),
  .init(name: "Beef")
]
