//
//  LegitimateRecipientViewModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 07/05/22.
//

import Foundation

struct LegitimateRecipientViewModel {
  private(set) var lineItems: [LineItem]
  private(set) var priceSection: PriceSection
  
  init(lineItems: [LineItem], priceSection: PriceSection) {
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
