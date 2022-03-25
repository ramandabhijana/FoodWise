//
//  CourierSessionRepository.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 16/03/22.
//

import Foundation
import Combine
import FirebaseFirestore

class CourierSessionRepository {
  private let db = Firestore.firestore()
  private let path = "courierSessions"
  
  public init() { }
  
  func createSession(courierId: String, geoPoint: GeoPoint) -> AnyPublisher<CourierSession, Error> {
    upsertSession(courierId: courierId, geoPoint: geoPoint, merge: false)
  }
  
  func updateSession(courierId: String, geoPoint: GeoPoint) -> AnyPublisher<CourierSession, Error> {
    upsertSession(courierId: courierId, geoPoint: geoPoint, merge: true)
  }
  
  func removeSession(courierId: String) -> AnyPublisher<Void, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      self.db.collection(self.path)
        .document(courierId)
        .delete { error in
          if let error = error { return promise(.failure(error)) }
          return promise(.success(()))
        }
    }
    .eraseToAnyPublisher()
  }
  
  private func upsertSession(courierId: String, geoPoint: GeoPoint, merge: Bool) -> AnyPublisher<CourierSession, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      let session = CourierSession(courierId: courierId, location: geoPoint)
      do {
        try self.db.collection(self.path)
          .document(session.courierId)
          .setData(from: session, merge: merge) { error in
            if let error = error {
              return promise(.failure(error))
            }
            return promise(.success(session))
          }
      } catch let error {
        return promise(.failure(error))
      }
    }
    .eraseToAnyPublisher()
  }
  
  //
  
    
  
  //
  
}
