//
//  CourierRepository.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 14/04/22.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

struct CourierRepository: ProfileUrlNameFetchableRepository {
  private let db = Firestore.firestore()
  private let path = "couriers"
  
  func getCourier(withId id: String) -> AnyPublisher<Courier, Error> {
    Future { promise in
      let docRef = db.collection(path).document(id)
      docRef.getDocument { snapshot, error in
        guard error == nil else { return promise(.failure(error!)) }
        if let snapshot = snapshot,
           snapshot.exists,
           let courier = try? snapshot.data(as: Courier.self) {
          return promise(.success(courier))
        } else {
          let error = NSError(
            domain: "",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "Unable to retrieve customer information"]
          )
          return promise(.failure(error))
        }
      }
    }
    .eraseToAnyPublisher()
  }
  
  func fetchNameAndProfilePictureUrl(ofUserWithId userId: String) -> AnyPublisher<(name: String, profilePictureUrl: URL?), Error> {
    Future { promise in
      let docRef = db.collection(path).document(userId)
      docRef.getDocument { snapshot, error in
        guard error == nil else { return promise(.failure(error!)) }
        if let snapshot = snapshot,
           snapshot.exists {
          do {
            let courier = try snapshot.data(as: Courier.self)
            return promise(.success((courier.name, courier.profilePictureUrl)))
          } catch {
            return promise(.failure(NSError.somethingWentWrong))
          }
        } else {
          let error = NSError(
            domain: "",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "Unable to retrieve courier information"]
          )
          return promise(.failure(error))
        }
      }
    }
    .eraseToAnyPublisher()
  }
}
