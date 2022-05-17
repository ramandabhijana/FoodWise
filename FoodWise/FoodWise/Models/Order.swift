//
//  Order.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 10/03/22.
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
  var items: [LineItem]
  let merchantShopFromId: String
  let customerId: String
  let customerProfilePicUrl: String
  let customerName: String
  let customerEmail: String
  let walletId: String?
  let shippingAddress: Address?
  var deliveryTaskId: String?
  
  internal init(id: String, date: Date, paymentMethod: OrderPaymentMethod, pickupMethod: OrderPickupMethod, status: OrderStatus, total: Double, deliveryCharge: Double, subtotal: Double, items: [LineItem], merchantShopFromId: String, customerId: String, customerProfilePicUrl: String, customerName: String, customerEmail: String, walletId: String?, shippingAddress: Address?) {
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
  
  var asObject: [String: Any] {
    ["id": id,
     "date": date,
     "paymentMethod": paymentMethod,
     "pickupMethod": pickupMethod,
     "status": status,
     "total": total,
     "deliveryCharge": deliveryCharge,
     "subtotal": subtotal,
     "items": items.map(\.asObject),
     "merchantShopFromId": merchantShopFromId,
     "customerId": customerId,
     "customerProfilePicUrl": customerProfilePicUrl,
     "customerName": customerName,
     "customerEmail": customerEmail,
     "walletId": walletId as Any,
     "shippingAddress": shippingAddress?.asObject as Any,
     "deliveryTaskId": deliveryTaskId as Any
    ]
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

extension Order {
  var formattedTotal: String { total.asIndonesianCurrencyString() }
  var formattedDeliveryCharge: String { deliveryCharge.asIndonesianCurrencyString() }
  var formattedSubtotal: String { subtotal.asIndonesianCurrencyString() }
}

extension Order {
  static var asPlaceholder: Order {
    .init(id: UUID().uuidString, date: .now, paymentMethod: .wallet, pickupMethod: .delivery, status: .pending, total: 50_000.00, deliveryCharge: 10_000.00, subtotal: 40_000.00, items: [.init(id: "1", foodId: "1", quantity: 1), .init(id: "2", foodId: "2", quantity: 2)], merchantShopFromId: "", customerId: "", customerProfilePicUrl: "", customerName: "", customerEmail: "", walletId: "", shippingAddress: nil)
  }
}
