//
//  SearchedKeyword.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 13/12/21.
//

import Foundation

struct SearchedKeyword: Identifiable {
  var id = UUID().uuidString
  var value: String
  let createdDate = Date()
}
