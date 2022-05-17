//
//  ReviewRepository.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 19/04/22.
//

import Foundation
import FirebaseFirestore
import Combine

struct ReviewRepository {
  private let path = "reviews"
  private let db = Firestore.firestore()
  
  func addReview(rating: Float, sentimentScore: Float, comments: String, foodId: String, customerId: String, customerName: String, customerProfilePicUrl: URL?) -> AnyPublisher<Void, Error> {
    Future { promise in
      let newReview = Review(rating: rating, sentimentScore: sentimentScore, comments: comments, foodId: foodId, customerId: customerId, customerName: customerName, customerProfilePicUrl: customerProfilePicUrl)
      do {
        try db.collection(path).document(newReview.id)
          .setData(from: newReview) { error in
            if let error = error {
              return promise(.failure(error))
            }
            return promise(.success(()))
          }
      } catch {
        promise(.failure(error))
      }
    }.eraseToAnyPublisher()
  }
  
  func getAllReviews(
    forFoodWithId foodId: String,
    limit: Int? = nil
  ) -> AnyPublisher<[Review], Error> {
    Future { promise in
      let query: Query = {
        let query = db.collection(path).whereField("foodId", isEqualTo: foodId)
        guard let limit = limit else { return query }
        return query.limit(to: limit)
      }()
      query.getDocuments { snapshot, error in
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
  
  //
  
  
  //
}
