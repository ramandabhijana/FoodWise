//
//  TaskHistoryRepository.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 18/04/22.
//

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
  
  func addCompletedDeliveryTask(
    _ task: DeliveryTask,
    forCourierWithId courierId: String
  ) -> AnyPublisher<Void, Error> {
    Future { promise in
      let taskHistory = DeliveryTaskHistory(
        courierId: courierId,
        task: task)
      do {
        try db.collection(path).document(task.taskId)
          .setData(from: taskHistory, completion: { error in
            if let error = error {
              return promise(.failure(error))
            }
            promise(.success(()))
          })
      } catch {
        promise(.failure(error))
      }
    }
    .eraseToAnyPublisher()
  }
  
  func getCompletedDeliveryTasks(forCourierId courierId: String) -> AnyPublisher<[DeliveryTask], Error> {
    Future { promise in
      db.collection(path)
        .whereField("courierId", isEqualTo: courierId)
        .getDocuments { snapshot, error in
          if let error = error {
            promise(.failure(error))
            return
          }
          let taskHistory = snapshot?.documents.compactMap({ document in
            do {
              return try document.data(as: DeliveryTaskHistory.self)
            } catch {
              print("Couldn't create delivery task history from document. \(error)")
              return nil
            }
          }) ?? [DeliveryTaskHistory]()
          return promise(.success(taskHistory.map(\.task)))
        }
    }.eraseToAnyPublisher()
  }
}
