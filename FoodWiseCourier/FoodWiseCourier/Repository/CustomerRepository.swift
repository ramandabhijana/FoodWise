//
//  CustomerRepository.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 05/05/22.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

protocol ProfileUrlNameFetchableRepository {
  func fetchNameAndProfilePictureUrl(ofUserWithId userId: String) -> AnyPublisher<(name: String, profilePictureUrl: URL?), Error>
}

struct CustomerRepository {
  private let db = Firestore.firestore()
  private let path = "customers"

  init() { }
  
  func incrementFoodSharedCount(by value: Int64 = 1, forCustomerId customerId: String) -> AnyPublisher<Void, Error> {
    Future { promise in
      let data = ["foodSharedCount": FieldValue.increment(value)]
      db.collection(path).document(customerId)
        .updateData(data) { error in
          if let error = error {
            promise(.failure(error))
          }
          promise(.success(()))
        }
    }
    .eraseToAnyPublisher()
  }
  
  func incrementFoodRescuedCount(by value: Int64 = 1, forCustomerId customerId: String) -> AnyPublisher<Void, Error> {
    Future { promise in
      let data = ["foodRescuedCount": FieldValue.increment(value)]
      db.collection(path).document(customerId)
        .updateData(data) { error in
          if let error = error {
            promise(.failure(error))
          }
          promise(.success(()))
        }
    }
    .eraseToAnyPublisher()
  }
  
}

extension CustomerRepository: ProfileUrlNameFetchableRepository {
  func fetchNameAndProfilePictureUrl(ofUserWithId userId: String) -> AnyPublisher<(name: String, profilePictureUrl: URL?), Error> {
    Future {  promise in
      let docRef = self.db.collection(self.path).document(userId)
      docRef.getDocument { snapshot, error in
        guard error == nil else { return promise(.failure(error!)) }
        if let snapshot = snapshot, snapshot.exists {
          do {
            let customer = try snapshot.data(as: Customer.self)
            return promise(.success((customer.fullName, customer.profileImageUrl)))
            
          } catch {
            return promise(.failure(error))
          }
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
}
