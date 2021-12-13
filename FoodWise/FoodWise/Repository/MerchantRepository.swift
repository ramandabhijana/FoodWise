//
//  MerchantRepository.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 11/12/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

final class MerchantRepository {
  private let db = Firestore.firestore()
  private let path = "merchants"
  
  private var cancellables = Set<AnyCancellable>()
  
  init() {
    
  }
  
  func getMerchant(withId id: String) -> AnyPublisher<Merchant, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      let docRef = self.db.collection(self.path).document(id)
      docRef.getDocument { snapshot, error in
        guard error == nil else { return promise(.failure(error!)) }
        if let snapshot = snapshot,
           snapshot.exists,
           let merchant = snapshot.data().flatMap(Merchant.init(object:))
        {
          return promise(.success(merchant))
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
  
  func getAllMerchants() -> AnyPublisher<[Merchant], Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      self.db.collection(self.path).getDocuments { snapshot, error in
        guard error == nil else { return promise(.failure(error!)) }
        let merchants = snapshot?.documents.compactMap{ document in
          do {
            return try document.data(as: Merchant.self)
          } catch let error {
            print("Couldn't create Merchant from document. \(error)")
            return nil
          }
        } ?? [Merchant]()
        return promise(.success(merchants))
      }
    }.eraseToAnyPublisher()
  }
  
  func getMerchants(withQuery query: String) -> AnyPublisher<[Merchant], Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      self.db.collection(self.path)
        .whereField("name", isGreaterThanOrEqualTo: query)
        .whereField("name", isLessThanOrEqualTo: query + "~")
        .getDocuments { snapshot, error in
        guard error == nil else { return promise(.failure(error!)) }
        let merchants = snapshot?.documents.compactMap{ document in
          do {
            return try document.data(as: Merchant.self)
          } catch let error {
            print("Couldn't create Merchant from document. \(error)")
            return nil
          }
        } ?? [Merchant]()
        return promise(.success(merchants))
      }
    }.eraseToAnyPublisher()
  }
  
}
