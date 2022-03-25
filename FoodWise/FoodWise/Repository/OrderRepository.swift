//
//  OrderRepository.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 10/03/22.
//

import Foundation
import Combine
import FirebaseFirestore

class OrderRepository {
  private let db = Firestore.firestore()
  private let path = "orders"
  
  public init() { }
  
  
  func createOrder(paymentMethod: OrderPaymentMethod, pickupMethod: OrderPickupMethod, total: Double, deliveryCharge: Double, subtotal: Double, items: [LineItem], merchantShopFromId: String, customerId: String, customerProfilePicUrl: String, customerName: String, customerEmail: String, walletId: String?, shippingAddress: Address?) -> AnyPublisher<Order, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      let order = Order(id: UUID().uuidString, date: Date.now, paymentMethod: paymentMethod, pickupMethod: pickupMethod, status: OrderStatus.pending, total: total, deliveryCharge: deliveryCharge, subtotal: subtotal, items: items, merchantShopFromId: merchantShopFromId, customerId: customerId, customerProfilePicUrl: customerProfilePicUrl, customerName: customerName, customerEmail: customerEmail, walletId: walletId, shippingAddress: shippingAddress)
      do {
        try self.db.collection(self.path)
          .document(order.id)
          .setData(from: order)
        promise(.success(order))
      } catch let error {
        promise(.failure(error))
      }
    }
    .eraseToAnyPublisher()
  }
}
