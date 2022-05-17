//
//  CourierSessionRepository.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 16/03/22.
//

import Foundation
import Combine
import FirebaseFirestore
import CoreLocation

class CourierSessionRepository {
  private let db = Firestore.firestore()
  private let path = "courierSessions"
  
  public init() { }
  
  func getSession(courierId: String) -> AnyPublisher<CourierSession?, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      self.db.collection(self.path).document(courierId)
        .getDocument { snapshot, error in
          if let error = error { return promise(.failure(error)) }
          guard let snapshot = snapshot, snapshot.exists else {
            return promise(.success(nil))
          }
          guard let session = try? snapshot.data(as: CourierSession.self) else {
            return promise(.failure(NSError()))
          }
          promise(.success(session))
        }
    }
    .eraseToAnyPublisher()
  }
  
  func createSession(courierId: String, coordinate: CLLocationCoordinate2D) -> AnyPublisher<CourierSession, Error> {
    upsertSession(courierId: courierId, coordinate: coordinate, merge: false)
  }
  
  func updateSession(courierId: String, coordinate: CLLocationCoordinate2D) -> AnyPublisher<CourierSession, Error> {
    upsertSession(courierId: courierId, coordinate: coordinate, merge: true)
  }
  
  func rejectTask(courierId: String) -> AnyPublisher<Void, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      let task: DeliveryTask? = nil
      let data: [String: Any] = ["deliveryTask": task as Any,
                                 "deliveryTaskId": task?.taskId as Any]
      self.db.collection(self.path).document(courierId)
        .setData(data, merge: true) { error in
          if let error = error {
            promise(.failure(error))
          } else {
            promise(.success(()))
          }
        }
    }
    .eraseToAnyPublisher()
  }
  
  func setItemPickedUp(for task: DeliveryTask, courierId: String) -> AnyPublisher<DeliveryTask, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      var updatedTask = task
      updatedTask.status?.append(.init(status: .itemsPickedUp, date: .now))
      let data: [String: Any] = ["deliveryTask": updatedTask.asObject]
      self.db.collection(self.path).document(courierId)
        .setData(data, merge: true) { error in
          if let error = error {
            promise(.failure(error))
          } else {
            promise(.success(updatedTask))
          }
        }
    }
    .eraseToAnyPublisher()
  }
  
  func finishTaskAndRemove(_ task: DeliveryTask,
                          fromSessionWithId courierId: String) -> AnyPublisher<DeliveryTask, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      var finishedTask = task
      finishedTask.status?.append(.init(status: .received, date: .now))
      let nilTask: DeliveryTask? = nil
      let data: [String: Any] = ["isBusy": false,
                                 "deliveryTask": nilTask as Any,
                                 "deliveryTaskId": nilTask?.taskId as Any]
      self.db.collection(self.path).document(courierId)
        .setData(data, merge: true) { error in
          if let error = error {
            promise(.failure(error))
          } else {
            print("\nSUCCESS: \(finishedTask)\n")
            promise(.success(finishedTask))
          }
        }
    }
    .eraseToAnyPublisher()
  }
  
  func acceptTask(_ task: DeliveryTask, courierId: String) -> AnyPublisher<DeliveryTask, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      var updatedTask = task
      updatedTask.deadlineCourierConfirmation = nil
      updatedTask.status = [.init(status: .requestAccepted, date: .now)]
      let data: [String: Any] = ["isBusy": true,
                                 "deliveryTask": updatedTask.asObject]
      self.db.collection(self.path).document(courierId)
        .setData(data, merge: true) { error in
          if let error = error {
            promise(.failure(error))
          } else {
            promise(.success(updatedTask))
          }
        }
    }
    .eraseToAnyPublisher()
  }
  
  func listenerForSession(courierId: String, block: @escaping FIRDocumentSnapshotBlock) -> ListenerRegistration {
    db.collection(path).document(courierId).addSnapshotListener(block)
  }
  
  func removeSession(courierId: String) -> AnyPublisher<Void, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      self.db.collection(self.path)
        .document(courierId)
        .delete { error in
          if let error = error { return promise(.failure(error)) }
          return promise(.success(()))
        }
    }
    .eraseToAnyPublisher()
  }
  
  private func upsertSession(courierId: String, coordinate: CLLocationCoordinate2D, merge: Bool) -> AnyPublisher<CourierSession, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      let session = CourierSession(courierId: courierId, location: coordinate)
      do {
        try self.db.collection(self.path)
          .document(session.courierId)
          .setData(from: session, merge: merge) { error in
            if let error = error {
              return promise(.failure(error))
            }
            return promise(.success(session))
          }
      } catch let error {
        return promise(.failure(error))
      }
    }
    .eraseToAnyPublisher()
  }
  
}
