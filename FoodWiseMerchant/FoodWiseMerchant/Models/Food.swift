//
//  Food.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 15/11/21.
//

import Foundation

struct Food: Identifiable, Codable, Equatable {
  var id: String
  let name: String
  var imagesUrl: [URL?]
  let categories: [FoodCategory]
  var stock: Int
  let keywords: [String]
  let description: String
  let retailPrice: Double
  let discountRate: Float
  let merchantId: String
  var price: Double
  var rating: Float?
  var reviewCount: Int?
  var sentimentScore: Float?
  
  var retailPriceString: String {
    retailPrice.asIndonesianCurrencyString()
  }
  
  var priceString: String {
    price.asIndonesianCurrencyString()
  }
  
  var discountRateString: String {
    "\(Int(discountRate))%"
  }
  
  var categoriesName: String {
    categories.map(\.name).joined(separator: ", ")
  }
  
  var keywordsString: String {
    keywords.joined(separator: ", ")
  }
  
  var sentimentScoreDescription: String {
    guard let sentimentScore = sentimentScore else { return "-" }
    switch sentimentScore {
    case 1.0...2.0: return "Disappointed"
    case 2.1...3.9: return "Neutral"
    case 4.0...5.0: return "Satisfied"
    default: return "-"
    }
  }
  
  var asObject: [String: Any] {
    ["id": id,
     "name": name,
     "imagesUrl": imagesUrl.map(\.?.absoluteString),
     "categories": categories.map(\.asObject),
     "stock": stock,
     "keywords": keywords,
     "description": description,
     "retailPrice": retailPrice,
     "discountRate": discountRate,
     "merchantId": merchantId,
     "price": price
    ]
  }
  
  init(id: String, name: String, imagesUrl: [URL?], categories: [FoodCategory], stock: Int, keywords: [String], description: String, retailPrice: Double, discountRate: Float, merchantId: String) {
    self.id = id
    self.name = name
    self.imagesUrl = imagesUrl
    self.categories = categories
    self.stock = stock
    self.keywords = keywords
    self.description = description
    self.retailPrice = retailPrice
    self.discountRate = discountRate
    self.price = retailPrice - (retailPrice * Double((discountRate * 0.01)))
    self.merchantId = merchantId
  }
  
  init() {
    id = UUID().uuidString
    name = "Unnamed food"
    imagesUrl = [URL(string: "")]
    categories = []
    stock = 0
    keywords = []
    description = ""
    retailPrice = 10_000
    discountRate = 20.0
    merchantId = ""
    price = 8_000
  }
  
  static func ==(lhs: Food, rhs: Food) -> Bool {
    lhs.id == rhs.id
  }
  
  static var asPlaceholderInstance: Food {
    .init(id: UUID().uuidString, name: "Unnamed food", imagesUrl: [URL(string: "https://assets.grab.com/wp-content/uploads/sites/4/2018/09/17104052/order-grabfood-fast-food-delivery.jpg")], categories: [], stock: 0, keywords: [], description: "", retailPrice: 10_000, discountRate: 20.0, merchantId: "")
  }
}
