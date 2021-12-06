//
//  Food.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 15/11/21.
//

import Foundation

struct Food: Identifiable, Codable {
  var id: String
  let name: String
  let imagesUrl: [URL?]
  let categories: [FoodCategory]
  var stock: Int
  let keywords: [String]
  let description: String
  let retailPrice: Double
  let discountRate: Float
  let merchantId: String
  
  var price: Double {
    retailPrice - (retailPrice * Double((discountRate * 0.01)))
  }
  
  var retailPriceString: String {
    retailPrice.asIndonesianCurrencyString()
  }
  
  var priceString: String {
    price.asIndonesianCurrencyString()
  }
  
  var discountRateString: String {
    "\(Int(discountRate)) %"
  }
  
  var categoriesName: String {
    categories.map(\.name).joined(separator: ", ")
  }
}
