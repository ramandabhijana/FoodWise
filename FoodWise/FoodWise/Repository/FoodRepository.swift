//
//  FoodRepository.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 06/12/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

final class FoodRepository {
  private let db = Firestore.firestore()
  private let path = "foods"
  
  public init() { }
  
  // TODO: add parameter (eg matching query, category, best deals)
  func getAllFoods() -> AnyPublisher<[Food], Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      self.db.collection(self.path)
        .addSnapshotListener { snapshot, error in
          guard error == nil else { return promise(.failure(error!)) }
          let foods = snapshot?.documents.compactMap{ document in
            do {
              return try document.data(as: Food.self)
            } catch let error {
              print("Couldn't create Food from document. \(error)")
              return nil
            }
          } ?? [Food]()
          return promise(.success(foods))
        }
    }.eraseToAnyPublisher()
  }
  
  func getFood(withId id: String) -> AnyPublisher<Food, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      self.db.collection(self.path).document(id)
        .getDocument { snapshot, error in
          guard error == nil else { return promise(.failure(error!)) }
          if let snapshot = snapshot,
             snapshot.exists,
             let food = try? snapshot.data(as: Food.self)
          {
            return promise(.success(food))
          } else {
            let error = NSError(
              domain: "",
              code: 0,
              userInfo: [NSLocalizedDescriptionKey: "Unable to retrieve food details"]
            )
            return promise(.failure(error))
          }
        }
    }.eraseToAnyPublisher()
  }
  
  func mergedFoods(ids foodIds: [String]) -> AnyPublisher<Food, Error> {
    let initialPublisher = getFood(withId: foodIds[0])
    let remainingIds = Array(foodIds.dropFirst())
    return remainingIds.reduce(initialPublisher) { partialResult, foodId in
      partialResult
        .merge(with: getFood(withId: foodId))
        .eraseToAnyPublisher()
    }
//    Future { [weak self] promise in
//
//    }.eraseToAnyPublisher()
  }
  
}
