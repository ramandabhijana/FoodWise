//
//  OrderReceiptViewModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 17/04/22.
//

import Foundation

struct OrderReceiptViewModel {
  private(set) var order: Order
  private(set) var merchantName: String
  
  var formattedDate: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd MMMM yyyy"
    return formatter.string(from: order.date.dateValue())
  }
  var formattedTime: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "hh:mm"
    return formatter.string(from: order.date.dateValue())
  }
  var giver: String {
    return order.pickupMethod == OrderPickupMethod.delivery.rawValue ? "courier" : "merchant"
  }
  
  init(order: Order, merchantName: String) {
    self.order = order
    self.merchantName = merchantName
  }
  
  
}
