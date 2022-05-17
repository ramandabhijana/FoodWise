//
//  OrderRepository.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 18/04/22.
//

import Foundation
import Combine
import FirebaseFirestore

struct OrderRepository {
  private let db = Firestore.firestore()
  private let path = "orders"
  
  func finishOrder(orderWithId orderId: String) -> AnyPublisher<Void, Error> {
    Future { promise in
      db.collection(path).document(orderId)
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
