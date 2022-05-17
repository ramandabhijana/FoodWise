//
//  Review.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 20/04/22.
//

import Foundation

struct Review: Codable, Identifiable {
  let id: String
  let date: Date
  let rating: Float
  let sentimentScore: Float
  let comments: String
  let foodId: String
  let customerId: String
  let customerName: String
  let customerProfilePicUrl: URL?
  
  var sentimentScoreDescription: String {
    switch sentimentScore {
    case 1.0...2.0: return "Disappointed"
    case 2.1...3.9: return "Neutral"
    case 4.0...5.0: return "Satisfied"
    default: return "-"
    }
  }
}

extension Review {
  static var asPlaceholder: Review {
    .init(id: UUID().uuidString, date: .now, rating: 4.0, sentimentScore: 4.0, comments: "", foodId: "", customerId: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", customerName: "Customer's name", customerProfilePicUrl: nil)
  }
}
