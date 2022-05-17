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
  
  func getOrders(orderedByCustomerWithId customerId: String,
                 withStatusIn status: [OrderStatus]) -> AnyPublisher<[Order], Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      self.db.collection(self.path)
        .whereField("customerId", isEqualTo: customerId)
        .whereField("status", in: status.map(\.rawValue))
        .getDocuments { snapshot, error in
          if let error = error { return promise(.failure(error)) }
          let orders = snapshot?.documents.compactMap({ document in
            do {
              return try document.data(as: Order.self)
            } catch let error {
              print("Couldn't create order from document. \(error)")
              return nil
            }
          }) ?? [Order]()
          return promise(.success(orders))
        }
    }
    .eraseToAnyPublisher()
  }
  
  func updateLineItems(with updatedLineItems: [LineItem], forOrderWithOrderId orderId: String) -> AnyPublisher<Void, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      let data = ["items": updatedLineItems.map(\.asObject)]
      self.db.collection(self.path).document(orderId)
        .setData(data, merge: true) { error in
          if let error = error { return promise(.failure(error)) }
          return promise(.success(()))
        }
    }
    .eraseToAnyPublisher()
  }
  
  
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
