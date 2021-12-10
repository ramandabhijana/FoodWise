//
//  CategoryRepository.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 08/12/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

final class CategoryRepository {
  private let db = Firestore.firestore()
  private let path = "foodCategories"
  
  public init() { }
  
  func createCategory(_ foodCategory: FoodCategory) -> AnyPublisher<Void, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      do {
        try self.db.collection(self.path)
          .document(foodCategory.id)
          .setData(from: foodCategory)
        promise(.success(()))
      } catch {
        promise(.failure(error))
      }
    }.eraseToAnyPublisher()
  }
}
