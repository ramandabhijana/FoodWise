//
//  FoodRepository.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 05/12/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

final class FoodRepository {
  private let db = Firestore.firestore()
  private let path = "foods"
  
  public init() { }
  
  public func createFood(
    withId id: String,
    name: String,
    imageUrls: [URL],
    categories: [FoodCategory],
    stock: Int,
    keywords: [String],
    description: String,
    retailPrice: Double,
    discountRate: Float,
    merchantId: String
  ) -> AnyPublisher<Food, Error> {
    let food = Food(id: id,
                    name: name,
                    imagesUrl: imageUrls,
                    categories: categories,
                    stock: stock,
                    keywords: keywords,
                    description: description,
                    retailPrice: retailPrice,
                    discountRate: discountRate,
                    merchantId: merchantId)
    return upsertFood(food)
  }
  
  private func upsertFood(_ food: Food, merge: Bool = false) -> AnyPublisher<Food, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      do {
        try self.db.collection(self.path)
          .document(food.id)
          .setData(from: food, merge: merge)
        return promise(.success(food))
      } catch let error {
        return promise(.failure(error))
      }
    }.eraseToAnyPublisher()
  }
  
  func getAllFoods(merchantId: String) -> AnyPublisher<[Food], Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      self.db.collection(self.path)
        .whereField("merchantId", isEqualTo: merchantId)
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
  
  func updateFoodStock(_ stock: Int, for food: Food) -> AnyPublisher<Void, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      let foodRef = self.db.collection(self.path).document(food.id)
      foodRef.updateData(["stock": stock]) { error in
        if let error = error {
          return promise(.failure(error))
        }
        return promise(.success(Void()))
      }
    }.eraseToAnyPublisher()
  }
}
