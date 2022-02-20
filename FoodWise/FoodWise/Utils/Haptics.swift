//
//  Haptics.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 19/02/22.
//

// https://stackoverflow.com/a/68088712
import UIKit

class Haptics {
  static let shared = Haptics()
  
  private init() { }
  
  func play(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle) {
    UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred()
  }
  
  func notify(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
    UINotificationFeedbackGenerator().notificationOccurred(feedbackType)
  }
}
