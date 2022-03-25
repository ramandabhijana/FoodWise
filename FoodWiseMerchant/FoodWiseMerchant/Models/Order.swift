//
//  Order.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 11/03/22.
//

import Foundation
import FirebaseFirestore

struct Order: Codable, Identifiable, Hashable {
  let id: String
  let date: Timestamp
  let paymentMethod: String
  let pickupMethod: String
  var status: String
  let total: Double
  let deliveryCharge: Double
  let subtotal: Double
  let items: [LineItem]
  let merchantShopFromId: String
  let customerId: String
  let customerProfilePicUrl: String
  let customerName: String
  let customerEmail: String
  let walletId: String?
  let shippingAddress: ShippingAddress?
  
  internal init(id: String, date: Date, paymentMethod: OrderPaymentMethod, pickupMethod: OrderPickupMethod, status: OrderStatus, total: Double, deliveryCharge: Double, subtotal: Double, items: [LineItem], merchantShopFromId: String, customerId: String, customerProfilePicUrl: String, customerName: String, customerEmail: String, walletId: String?, shippingAddress: ShippingAddress?) {
    self.id = id
    self.date = Timestamp(date: date)
    self.paymentMethod = paymentMethod.rawValue
    self.pickupMethod = pickupMethod.rawValue
    self.status = status.rawValue
    self.total = total
    self.deliveryCharge = deliveryCharge
    self.subtotal = subtotal
    self.items = items
    self.merchantShopFromId = merchantShopFromId
    self.customerId = customerId
    self.customerProfilePicUrl = customerProfilePicUrl
    self.customerName = customerName
    self.customerEmail = customerEmail
    self.walletId = walletId
    self.shippingAddress = shippingAddress
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  static func == (lhs: Order, rhs: Order) -> Bool {
    lhs.id == rhs.id
  }
}

enum OrderPaymentMethod: String {
  case cash = "CASH"
  case wallet = "WALLET"
}

enum OrderPickupMethod: String {
  case selfPickup = "SELF-PICKUP"
  case delivery = "DELIVERY"
}

enum OrderStatus: String {
  case pending = "PENDING"
  case accepted = "ACCEPTED"
  case rejected = "REJECTED"
  case finished = "FINISHED"
}
