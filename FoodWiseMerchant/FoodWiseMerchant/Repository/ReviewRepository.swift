//
//  ReviewRepository.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 20/04/22.
//

import Foundation
import FirebaseFirestore
import Combine

struct ReviewRepository {
  private let path = "reviews"
  private let db = Firestore.firestore()
  
  public init() { }
  
  func getAllReviews(forFoodWithId foodId: String) -> AnyPublisher<[Review], Error> {
    Future { promise in
      db.collection(path)
        .whereField("foodId", isEqualTo: foodId)
        .getDocuments { snapshot, error in
          if let error = error {
            return promise(.failure(error))
          }
          let reviews = snapshot?.documents.compactMap({ document in
            do {
              return try document.data(as: Review.self)
            } catch let error {
              print("Could not fetch reviews for food. Error: \(error)")
              return nil
            }
          }) ?? [Review]()
          return promise(.success(reviews))
        }
    }
    .eraseToAnyPublisher()
  }
}
