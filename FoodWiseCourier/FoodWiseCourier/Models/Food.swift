//
//  Food.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 15/11/21.
//

import Foundation

struct Food: Identifiable {
  var id: UUID = UUID()
  let name: String
  let imageUrl: URL?
  let retailPrice: Double
  let discountRate: Float
  let overallRating: Float
  
  var price: Double {
    retailPrice - (retailPrice * Double((discountRate * 0.01)))
  }
  
  var retailPriceString: String {
    retailPrice.asIndonesianCurrencyString()
  }
  
  var priceString: String {
    price.asIndonesianCurrencyString()
  }
  
  var overallRatingString: String {
    String(format: "%.1f", overallRating)
  }
  
  var discountRateString: String {
    "\(Int(discountRate)) %"
  }
}

extension Food {
  // Interim presentation sample data
  static var sampleData: [Food] {
    [
      .init(name: "Nasi Lemak Special", imageUrl: URL(string: "https://assets.grab.com/wp-content/uploads/sites/4/2018/09/17104052/order-grabfood-fast-food-delivery.jpg"), retailPrice: 20_000, discountRate: 60, overallRating: 4),
      .init(name: "Soto Sapi", imageUrl: URL(string: "https://www.piknikdong.com/wp-content/uploads/2021/07/Soto-Daging-Sapi-min.jpg"), retailPrice: 45_000, discountRate: 60, overallRating: 4.5),
      .init(name: "Nasi Padang", imageUrl: URL(string: "https://foodcourt.id/wp-content/uploads/2020/07/nasi-padang-rendang.jpg"), retailPrice: 30_000, discountRate: 55, overallRating: 4.0),
      .init(name: "Takoyaki", imageUrl: URL(string: "https://img-global.cpcdn.com/recipes/b59d09bd24c069a0/1200x630cq70/photo.jpg"), retailPrice: 15_000, discountRate: 20, overallRating: 3.5),
      .init(name: "Roti naan", imageUrl: URL(string: "https://www.vegrecipesofindia.com/wp-content/uploads/2013/07/naan-recipe-2.jpg"), retailPrice: 20_000, discountRate: 50, overallRating: 4.5)
    ]
  }
  
  static var sampleSection: [String] {
    ["Best Deals", "Most Popular"]
  }
}
