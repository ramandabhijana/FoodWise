//
//  DeliveryTaskRepository.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 06/04/22.
//

import Foundation
import Combine
import FirebaseFirestore
import CoreLocation
import GeoFireUtils

struct DeliveryTaskRepository {
  private let db = Firestore.firestore()
  
  // Nested type on session document, no need separate path
  private let path = "courierSessions"
  
  func getCourierSession(withDeliveryTaskId deliveryTaskId: String) -> AnyPublisher<CourierSession?, Error> {
    Future { promise in
      db.collection(path)
        .whereField("deliveryTaskId", isEqualTo: deliveryTaskId)
        .getDocuments { snapshot, error in
          if let error = error { return promise(.failure(error)) }
          let sessions = snapshot?.documents.compactMap({ document in
            do {
              return try document.data(as: CourierSession.self)
            } catch let error {
              print("Couldn't create session from document. \(error)")
              return nil
            }
          }) ?? [CourierSession]()
          if sessions.count == 1, let session = sessions.first {
            promise(.success(session))
          } else {
            promise(.success(nil))
          }
        }
    }
    .eraseToAnyPublisher()
  }
  
  func getAllSessions(
    withinRadiusInM radius: Double,
    ofLocation centerLocation: CLLocation,
    completion: @escaping (Result<[CourierSession], Error>) -> Void
  ) {
    
    var availableSessions: [CourierSession] = []
    let serialQueue = DispatchQueue(label: "serial_queue")
    
    let queryBounds = GFUtils.queryBounds(
      forLocation: centerLocation.coordinate,
      withRadius: radius)
    
    var queries = queryBounds.map { bound in
      db.collection(path)
        .order(by: "geohash")
        .start(at: [bound.startValue])
        .end(at: [bound.endValue])
    }
    var queriesCapacityCount = queries.count
    
    for _ in queries.indices {
      print("\nFQueries count: \(queries.count)\n")
      let query = queries.removeFirst()
      print("\nFQueries after remove first: \(queries.count)\n")
      query.getDocuments(source: .server) { snapshot, error in
        if let error = error {
          completion(.failure(error))
          return
        }
        
        serialQueue.sync {
          print("\nFirst queue\n")
          queriesCapacityCount -= 1
          
          let sessions = snapshot?.documents.compactMap { doc in
            do {
              let session = try doc.data(as: CourierSession.self)
              guard session.deliveryTask == nil else { return nil }
              let sessionLocation = CLLocation(
                latitude: session.location.latitude,
                longitude: session.location.longitude)
              let distance = sessionLocation.distance(from: centerLocation)
              print("\n\(distance <= radius)\n")
              return distance <= radius ? session : nil
            } catch let error {
              print("Couldn't create CourierSession from document. \(error)")
              return nil
            }
          } ?? [CourierSession]()
          
          availableSessions.append(contentsOf: sessions)
        }
        
        serialQueue.sync {
          print("\nSecond queue\n")
          if queriesCapacityCount == 0 {
            completion(.success(availableSessions))
          }
        }
      }
      
    }
    
  }
  
  
  func assignTask(
    _ task: DeliveryTask,
    toSessionWithinRadiusInM radius: Double,
    centerLocation: CLLocation,
    completion: @escaping (Result<DeliveryTask, Error>) -> Void
  ) {
    getAllSessions(withinRadiusInM: radius, ofLocation: centerLocation) { result in
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let sessions):
        print("sessions: \(sessions)")
//        if sessions.isEmpty {
//          completion(.failure(CourierSessionError.notAvailable))
//          return
//        }
        var shuffledSessions = sessions.shuffled()
        
        let maximumRejectionCount = 3
        var rejectionCount = 0
        
        func addAndListen() {
          guard !shuffledSessions.isEmpty,
                rejectionCount < maximumRejectionCount else {
            completion(.failure(CourierSessionError.notAvailable))
            return
          }
          var courierConfirmationListener: ListenerRegistration? = nil
          
          let currentSession = shuffledSessions.remove(at: 0)
          
          isSessionBusy(for: currentSession) { result in
            if case .failure = result {
              print("Checking session busy failed")
            }
            if case .success(let busy) = result {
              
              // we make sure the current session is not busy, otherwise move to the next one
              guard !busy else { return addAndListen() }
              
              var updatedDeadlineTask = task
              updatedDeadlineTask.deadlineCourierConfirmation = Timestamp(date: .now + 32)
              
              var afterDeadlineWork: DispatchWorkItem?
              
              addDeliveryTask(
                updatedDeadlineTask,
                toSessionWithId: currentSession.courierId
              ) { error in
                if let error = error {
                  print("Error adding delivery task: \(error)")
                }
                
                courierConfirmationListener = listenForCourierConfirmation(courierId: currentSession.courierId) { snapshot, error in
                  print("\nNew snapshot\n")
                  if let error = error {
                    print("listener error: \(error)")
                  }
                  
                  guard let snapshot = snapshot
                        
                  else {
                    print("\nSomething went wrong\n")
                    return
                    
                  }
                  
                  let session = try! snapshot.data(as: CourierSession.self)
                  
                  if let deliveryTask = session.deliveryTask {
                    if let deadline = deliveryTask.deadlineConfirmationDate {
                      // we're waiting for the deadline
                      print("waiting deadline")
                      afterDeadlineWork = DispatchWorkItem {
                        print("performing work after 30secs")
                        let passingDeadline = deadline <= .now
                        print("isPassingDeadline: \(passingDeadline)")
                        if passingDeadline {
                          resetTask(sessionCourierId: session.courierId)
                          courierConfirmationListener?.remove()
                          addAndListen()
                        }
                      }
                      DispatchQueue.main.asyncAfter(deadline: .now() + 32,
                                                    execute: afterDeadlineWork!)
                    } else {
                      // we're accepted, we will cancel the work
                      afterDeadlineWork?.cancel()
                      courierConfirmationListener?.remove()
                      completion(.success(deliveryTask))
                      return
                    }
                  } else {
                    // if session's task is nil we know we're rejected
                    // we cancel the waiting for confirmation when the courier rejected the task
                    // by the deadline
                    afterDeadlineWork?.cancel()
                    
                    rejectionCount += 1
                    courierConfirmationListener?.remove()
                    addAndListen()
                  }
                }
              }
            }
          }
        }
        print("\ncalling addAndListen\n")
        addAndListen()
      }
    }
  }
  
  func isSessionBusy(for session: CourierSession,
                     completion: @escaping (Result<Bool, Error>) -> Void) {
    db.collection(path).document(session.courierId)
      .getDocument(as: CourierSession.self) { result in
        switch result {
        case .failure(let error):
          completion(.failure(error))
        case .success(let session):
          // busy if task is not nil
          completion(.success(session.deliveryTask != nil))
        }
      }
  }
  
  func addDeliveryTask(
    _ task: DeliveryTask?,
    toSessionWithId sessionId: String,
    completion: @escaping ((Error?) -> Void)
  ) {
    db.collection(path).document(sessionId)
      .setData(["deliveryTask": task?.asObject as Any,
                "deliveryTaskId": task?.taskId as Any],
               merge: true,
               completion: completion)
  }
  
  func listenForCourierConfirmation(courierId: String, listener: @escaping FIRDocumentSnapshotBlock) -> ListenerRegistration {
    db.collection(path).document(courierId).addSnapshotListener(listener)
  }
  
  func resetTask(sessionCourierId: String) {
    addDeliveryTask(nil, toSessionWithId: sessionCourierId, completion: { _ in })
  }
}

enum CourierSessionError: Error, LocalizedError {
  case notAvailable
  
  var errorDescription: String? {
    switch self {
    case .notAvailable: return "Couldn't find a courier"
    }
  }
}
