//
//  FoodReview.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 19/04/22.
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
  
  internal init(rating: Float, sentimentScore: Float, comments: String, foodId: String, customerId: String, customerName: String, customerProfilePicUrl: URL?) {
    self.id = UUID().uuidString
    self.date = .now
    self.rating = rating
    self.sentimentScore = sentimentScore
    self.comments = comments
    self.foodId = foodId
    self.customerId = customerId
    self.customerName = customerName
    self.customerProfilePicUrl = customerProfilePicUrl
  }
}
