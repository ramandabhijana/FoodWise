//
//  LegitimateRecipientViewModel.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 18/04/22.
//

import Foundation

struct LegitimateRecipientViewModel {
  private(set) var lineItems: [LineItem]
  private(set) var priceSection: PriceSection
  private(set) var isPaid: Bool
  private(set) var isUsingDelivery: Bool
  
  var paidInformation: String {
    if priceSection.subtotal == 0.0 { // donation
      if priceSection.deliveryCharge > 0.0 {
        return "The customer has not paid for the delivery"
      } else {
        return ""
      }
    }
    return "The customer has \(isPaid ? "" : "not ")paid for the order \(isUsingDelivery ? "& delivery" : "")"
  }
  
  init(isPaid: Bool, isUsingDelivery: Bool, lineItems: [LineItem], priceSection: PriceSection) {
    self.isPaid = isPaid
    self.isUsingDelivery = isUsingDelivery
    self.lineItems = lineItems
    self.priceSection = priceSection
  }
  
}

extension LegitimateRecipientViewModel {
  struct LineItem: Identifiable {
    let id: String
    let name: String
    let qty: Int
    let price: Double
  }
  
  struct PriceSection {
    let subtotal: Double
    let deliveryCharge: Double
    let total: Double
  }
}
