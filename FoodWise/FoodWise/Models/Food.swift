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
  let imagesUrl: [URL?]
  let categories: [FoodCategory]
  var stock: Int
  let keywords: [String]
  let description: String
  let retailPrice: Double
  let discountRate: Float
  let merchantId: String
  var price: Double
  
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
  
  static var asPlaceholderInstance: Food {
    .init(id: UUID().uuidString, name: "Unnamed food", imagesUrl: [URL(string: "")], categories: [], stock: 0, keywords: [], description: "", retailPrice: 10_000, discountRate: 20.0, merchantId: "")
  }
  
  static func ==(lhs: Food, rhs: Food) -> Bool {
    lhs.id == rhs.id
  }
}

enum FeaturedCriteria {
  case bestDeals // disc >= 50%
  case under10k //
  case mostLoved // rating >= 4
}

extension Food {
  // Interim presentation sample data
//  static var sampleData: [Food] {
//    [
//      .init(name: "Nasi Lemak Special", imageUrl: URL(string: "https://assets.grab.com/wp-content/uploads/sites/4/2018/09/17104052/order-grabfood-fast-food-delivery.jpg"), retailPrice: 20_000, discountRate: 60, overallRating: 4),
//      .init(name: "Soto Sapi", imageUrl: URL(string: "https://www.piknikdong.com/wp-content/uploads/2021/07/Soto-Daging-Sapi-min.jpg"), retailPrice: 45_000, discountRate: 60, overallRating: 4.5),
//      .init(name: "Nasi Padang", imageUrl: URL(string: "https://foodcourt.id/wp-content/uploads/2020/07/nasi-padang-rendang.jpg"), retailPrice: 30_000, discountRate: 55, overallRating: 4.0),
//      .init(name: "Takoyaki", imageUrl: URL(string: "https://img-global.cpcdn.com/recipes/b59d09bd24c069a0/1200x630cq70/photo.jpg"), retailPrice: 15_000, discountRate: 20, overallRating: 3.5),
//      .init(name: "Roti naan", imageUrl: URL(string: "https://www.vegrecipesofindia.com/wp-content/uploads/2013/07/naan-recipe-2.jpg"), retailPrice: 20_000, discountRate: 50, overallRating: 4.5)
//    ]
//  }
  
  struct HomeSection: Hashable {
    var name: String
    var criteria: FeaturedCriteria
  }
  
  static let homeSection: [HomeSection] = [
    .init(name: "Best Deals", criteria: .bestDeals),
    .init(name: "Under IDR 10K", criteria: .under10k),
    .init(name: "Most Loved", criteria: .mostLoved),
  ]
  
  static var sampleData: [Food] {
    [
      .init(id: "26A40BA2-7534-4C62-B0C1-3FEDEAA6097C", name: "Food612", imagesUrl: [.init(string: "https://firebasestorage.googleapis.com:443/v0/b/foodwise-c118c.appspot.com/o/food_pictures%2F26A40BA2-7534-4C62-B0C1-3FEDEAA6097C_0?alt=media&token=257e3763-6b79-47c8-bfc9-a4aa357a1012"), .init(string: "https://firebasestorage.googleapis.com:443/v0/b/foodwise-c118c.appspot.com/o/food_pictures%2F2F302D79-8562-4780-84B3-FA57FB15D30C_0?alt=media&token=f2f19ea5-daba-48be-a36c-640e2d28ba2f"), .init(string: "https://firebasestorage.googleapis.com:443/v0/b/foodwise-c118c.appspot.com/o/food_pictures%2F2F302D79-8562-4780-84B3-FA57FB15D30C_1?alt=media&token=d4e23927-a225-4fef-b52e-89792eb58c28")], categories: [FoodCategories.indian.category], stock: 2, keywords: ["Foodsix"], description: "", retailPrice: 15000.0, discountRate: 20.0, merchantId: "nwcRFSc67Oga5hBmA5WOyLjOQOk1")
    ]
  }
  /*
   [FoodWise.Food(id: "26A40BA2-7534-4C62-B0C1-3FEDEAA6097C", name: "Food612", imagesUrl: [Optional(https://firebasestorage.googleapis.com:443/v0/b/foodwise-c118c.appspot.com/o/food_pictures%2F26A40BA2-7534-4C62-B0C1-3FEDEAA6097C_0?alt=media&token=257e3763-6b79-47c8-bfc9-a4aa357a1012)], categories: [FoodWise.FoodCategory(id: 88D0B01C-454C-433C-B10B-515C5E378939, name: "Indian")], stock: 2, keywords: ["Foodsix"], description: "", retailPrice: 15000.0, discountRate: 20.0, merchantId: "nwcRFSc67Oga5hBmA5WOyLjOQOk1"), FoodWise.Food(id: "2F302D79-8562-4780-84B3-FA57FB15D30C", name: "Test", imagesUrl: [Optional(https://firebasestorage.googleapis.com:443/v0/b/foodwise-c118c.appspot.com/o/food_pictures%2F2F302D79-8562-4780-84B3-FA57FB15D30C_0?alt=media&token=f2f19ea5-daba-48be-a36c-640e2d28ba2f), Optional(https://firebasestorage.googleapis.com:443/v0/b/foodwise-c118c.appspot.com/o/food_pictures%2F2F302D79-8562-4780-84B3-FA57FB15D30C_1?alt=media&token=d4e23927-a225-4fef-b52e-89792eb58c28), Optional(https://firebasestorage.googleapis.com:443/v0/b/foodwise-c118c.appspot.com/o/food_pictures%2F2F302D79-8562-4780-84B3-FA57FB15D30C_2?alt=media&token=9699f687-0ec8-4393-82ed-cca1da95a1e0)], categories: [FoodWise.FoodCategory(id: FDD4EB4E-BD62-4D9C-BD0D-9B83F02677EA, name: "Rice"), FoodWise.FoodCategory(id: 27BBC1AA-EC86-47CE-BE9F-2B0617E4B355, name: "Pork")], stock: 2, keywords: ["Nasi", "babi guling"], description: "Only few left grab fast!", retailPrice: 15000.0, discountRate: 50.0, merchantId: "nwcRFSc67Oga5hBmA5WOyLjOQOk1"), FoodWise.Food(id: "424131C8-EF90-46AE-90EE-F9FC05581B5D", name: "Tdf", imagesUrl: [Optional(https://firebasestorage.googleapis.com:443/v0/b/foodwise-c118c.appspot.com/o/food_pictures%2F424131C8-EF90-46AE-90EE-F9FC05581B5D_0?alt=media&token=d59c7b44-4684-455b-ad3e-31956fd9991d)], categories: [FoodWise.FoodCategory(id: 266EB973-78CD-400B-979B-44F0CB3E5B93, name: "Sweets")], stock: 25, keywords: ["Gift "], description: "", retailPrice: 10000.0, discountRate: 20.0, merchantId: "nwcRFSc67Oga5hBmA5WOyLjOQOk1"), FoodWise.Food(id: "73BAAD2D-B80B-4315-89AF-6DBAF0F324C4", name: "6food", imagesUrl: [Optional(https://firebasestorage.googleapis.com:443/v0/b/foodwise-c118c.appspot.com/o/food_pictures%2F73BAAD2D-B80B-4315-89AF-6DBAF0F324C4_0?alt=media&token=0aa5a491-35d7-464a-a906-ac419aff16f4)], categories: [FoodWise.FoodCategory(id: 84229BBF-57D9-4A2C-BDBE-B40786956CC2, name: "Japanese")], stock: 1, keywords: ["Garre"], description: "", retailPrice: 10000.0, discountRate: 50.0, merchantId: "nwcRFSc67Oga5hBmA5WOyLjOQOk1"), FoodWise.Food(id: "EB963E5F-C0A0-451E-8CF8-E057E766641A", name: "Babi guling", imagesUrl: [Optional(https://firebasestorage.googleapis.com:443/v0/b/foodwise-c118c.appspot.com/o/food_pictures%2FEB963E5F-C0A0-451E-8CF8-E057E766641A_0?alt=media&token=09a3d78b-7f36-4bfa-97e0-28f3a6101c13), Optional(https://firebasestorage.googleapis.com:443/v0/b/foodwise-c118c.appspot.com/o/food_pictures%2FEB963E5F-C0A0-451E-8CF8-E057E766641A_1?alt=media&token=f710ad94-5ff7-40dc-947a-f67d9bf34a4a)], categories: [FoodWise.FoodCategory(id: A541DC96-D32C-42AB-8B98-79AF2D29FBFC, name: "Noodle"), FoodWise.FoodCategory(id: 5CE4B846-0BED-4BCE-B241-0AD98EACB73C, name: "Pork")], stock: 2, keywords: ["Mi", "babi"], description: "Grab fast", retailPrice: 10000.0, discountRate: 20.0, merchantId: "nwcRFSc67Oga5hBmA5WOyLjOQOk1")]
   */
}
