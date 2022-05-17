//
//  DeliveryTaskHistoryRepository.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 19/04/22.
//

import Foundation

import Foundation
import Combine
import FirebaseFirestore

struct DeliveryTaskHistory: Codable {
  let courierId: String
  let task: DeliveryTask
  
  var asObject: [String: Any] {
    ["courierId": courierId, "task": task.asObject]
  }
}

struct TaskHistoryRepository {
  private let db = Firestore.firestore()
  private let path = "taskHistory"
  
  public init() { }
  
  func getDeliveryTask(withTaskId taskId: String) -> AnyPublisher<DeliveryTaskHistory?, Error> {
    Future { promise in
      db.collection(path).document(taskId)
        .getDocument(completion: { snapshot, error in
          guard let snapshot = snapshot, snapshot.exists else {
            promise(.success(nil))
            return
          }
          promise(.success(try? snapshot.data(as: DeliveryTaskHistory.self)))
        })
    }
    .eraseToAnyPublisher()
  }
  
  func addCompletedDeliveryTask(
    _ task: DeliveryTask,
    forCourierWithId courierId: String
  ) -> AnyPublisher<Void, Error> {
    Future { promise in
      let taskHistory = DeliveryTaskHistory(
        courierId: courierId,
        task: task)
      db.collection(path).document(task.taskId)
        .setData(taskHistory.asObject) { error in
          if let error = error {
            return promise(.failure(error))
          }
          promise(.success(()))
        }
    }
    .eraseToAnyPublisher()
  }
}
