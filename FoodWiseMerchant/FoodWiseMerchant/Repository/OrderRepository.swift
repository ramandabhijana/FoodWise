//
//  OrderRepository.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 11/03/22.
//

import Foundation
import Combine
import FirebaseFirestore

class OrderRepository {
  private let db = Firestore.firestore()
  private let path = "orders"
  
  public init() { }
  
  func fetchAllOrdersForMerchant(with merchantId: String) -> AnyPublisher<[Order], Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      self.db.collection(self.path)
        .whereField("merchantShopFromId", isEqualTo: merchantId)
        .getDocuments { snapshot, error in
          guard error == nil else {
            return promise(.failure(error ?? NSError()))
          }
          let orders = snapshot?.documents.compactMap { document in
            do {
              return try document.data(as: Order.self)
            } catch let error {
              print("Couldn't create Order from document. \(error)")
              return nil
            }
          } ?? [Order]()
          return promise(.success(orders))
        }
    }
    .eraseToAnyPublisher()
  }
  
  func confirmOrder(orderWithId orderId: String, status: OrderStatus, deliveryTaskId: String? = nil) -> AnyPublisher<Void, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      self.db.collection(self.path).document(orderId)
        .setData(["status": status.rawValue,
                  "deliveryTaskId": deliveryTaskId as Any],
                 merge: true
        ) { error in
          if let error = error {
            promise(.failure(error))
            return
          }
          return promise(.success(()))
        }
    }
    .eraseToAnyPublisher()
  }
  
  func fetchPendingSelfPickupOrdersForMerchant(withId merchantId: String) -> AnyPublisher<[Order], Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      self.db.collection(self.path)
        .whereField("merchantShopFromId", isEqualTo: merchantId)
        .whereField("status", isEqualTo: OrderStatus.accepted.rawValue)
        .whereField("pickupMethod", isEqualTo: OrderPickupMethod.selfPickup.rawValue)
        .getDocuments { snapshot, error in
          guard error == nil else {
            return promise(.failure(error ?? NSError()))
          }
          let orders = snapshot?.documents.compactMap { document in
            do {
              return try document.data(as: Order.self)
            } catch let error {
              print("Couldn't create Order from document. \(error)")
              return nil
            }
          } ?? [Order]()
          return promise(.success(orders))
        }
    }
    .eraseToAnyPublisher()
  }
  
  func finishOrder(orderWithId orderId: String) -> AnyPublisher<Void, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      self.db.collection(self.path).document(orderId)
        .setData(["status": OrderStatus.finished.rawValue], merge: true) { error in
          if let error = error {
            promise(.failure(error))
            return
          }
          return promise(.success(()))
        }
    }
    .eraseToAnyPublisher()
  }
  
}
