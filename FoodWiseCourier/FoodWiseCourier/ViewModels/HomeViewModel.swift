//
//  HomeViewModel.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 16/03/22.
//

import Foundation
import Combine
import CoreLocation
import UIKit
import FirebaseFirestore

class HomeViewModel: ObservableObject {
  @Published var isOnline: Bool = false {
    didSet {
      if isOnline {
        locationManager.startMonitoring()
      } else {
        locationManager.stopLocationService()
      }
    }
  }
  @Published var onDutyTask: DeliveryTask?
  @Published var showingIncomingTaskView = false
  @Published var isOnDuty: Bool = false
//  @Published var isOnDutyWithTask: (Bool, DeliveryTask?) = (false, nil)
  
  private(set) var sessionRepository: CourierSessionRepository
  private let trackingRepository: SessionTrackingRepository
  private let locationManager = LocationManager.shared
  private let incomingTaskSubject: PassthroughSubject<DeliveryTask, Never> = .init()
  
  private(set) var currentLocation: CLLocation? = nil
  private(set) var currentCoordinate: CLLocationCoordinate2D? = nil
  
//  private var coordinateSubject: PassthroughSubject<CLLocationCoordinate2D, Never> = .init()
  private(set) var session: CourierSession? = nil
  
  private var subscriptions: Set<AnyCancellable> = []
  
  var onDutyTaskPublisher: AnyPublisher<DeliveryTask, Never> {
    $onDutyTask.compactMap({$0}).eraseToAnyPublisher()
  }
  var incomingTaskPublisher: AnyPublisher<DeliveryTask, Never> {
    incomingTaskSubject.eraseToAnyPublisher()
  }
  var statusText: String { isOnline ? "ONLINE" : "OFFLINE" }
  /*
  var coordinatePublisher: AnyPublisher<CLLocationCoordinate2D, Never> {
    coordinateSubject.eraseToAnyPublisher()
  }
  */
  
  let onlineInfoText = "We store your location to find you a customer"
  let offlineInfoText = "While in offline mode, we no longer store your location"
  
  var sessionListener: ListenerRegistration?
  
  init(
    courierPublisher: AnyPublisher<Courier, Never>,
    sessionRepository: CourierSessionRepository = CourierSessionRepository(),
    trackingRepository: SessionTrackingRepository = SessionTrackingRepository()
  ) {
    self.sessionRepository = sessionRepository
    self.trackingRepository = trackingRepository
    // check if is on duty (fetch from realtime db)
    // add onDuty property to session
    
    courierPublisher.sink { [weak self] courier in
      self?.getSession(courierId: courier.id)
    }
    .store(in: &subscriptions)
    locationManager.locationPublisher
      .sink { [weak self] clLocation in
        print("locationManager.locationPublisher: \(clLocation)")
        
        self?.currentLocation = clLocation
        self?.currentCoordinate = clLocation.coordinate
        self?.updateSession()
      }
      .store(in: &subscriptions)
//    NotificationCenter.default.publisher(for: UIScene.didDisconnectNotification)
//      .sink { [unowned self] _ in
//        print("\n" + "didDisconnectNotification" + "\n")
//        self.removeSession()
//      }
//      .store(in: &subscriptions)
  }
  
  deinit {
    print("deinit homevm")
    sessionListener?.remove()
  }
  
  func getSession(courierId: String) {
    sessionRepository.getSession(courierId: courierId)
      .sink { completion in
        if case .failure(let error) = completion {
          print("failed to checkSessionAvailable with error: \(error)")
        }
      } receiveValue: { [weak self] session in
        self?.session = session
        if let session = session {
          self?.isOnline = true
          self?.isOnDuty = session.isBusy
          self?.listenForTask(courierId: courierId)
        }
        self?.onDutyTask = session?.deliveryTask
        self?.updateSession()
      }
      .store(in: &subscriptions)
  }
  
  func createSession(courierId: String) {
    print("\nCreating session\n")
    guard let currentCoordinate = currentCoordinate,
          session == nil else { return }
    
    sessionRepository.createSession(
      courierId: courierId,
      coordinate: currentCoordinate
    )
      .subscribe(on: DispatchQueue.global(qos: .utility))
      .sink { completion in
        if case .failure(let error) = completion {
          print("failed to createSession with error: \(error)")
        }
      } receiveValue: { [weak self] session in
        guard let self = self else { return }
        self.session = session
        self.listenForTask(courierId: courierId)
      }
      .store(in: &subscriptions)
  }
  
  func updateSession() {
    // if onDuty -> Firebase realtime else Firestore
    guard
      let currentLocation = currentLocation,
      let session = session else { return }
    if isOnDuty {
      updateTrackingSession(sessionId: session.courierId,
                            location: currentLocation)
    } else {
      sessionRepository.updateSession(
        courierId: session.courierId,
        coordinate: currentLocation.coordinate
      )
        .subscribe(on: DispatchQueue.global(qos: .utility))
        .sink { completion in
          if case .failure(let error) = completion {
            print("failed to createSession with error: \(error)")
          }
        } receiveValue: { [weak self] session in
          self?.session = session
        }
        .store(in: &subscriptions)
    }
  }
  
  func removeTrackingSession() {
    guard let session = session else { return }
    trackingRepository.deleteSession(sessionId: session.courierId)
  }
  
  func removeSession() {
    guard let session = session else { return }
    sessionRepository.removeSession(courierId: session.courierId)
      .subscribe(on: DispatchQueue.global(qos: .background))
      .sink { completion in
        if case .failure(let error) = completion {
          print("failed to removeSession with error: \(error)")
        }
      } receiveValue: { [weak self] _ in
        self?.session = nil
        self?.sessionListener?.remove()
      }
      .store(in: &subscriptions)
  }
  
  func listenAcceptedTaskPublisher(_ publisher: AnyPublisher<DeliveryTask, Never>) {
    publisher
      .sink { [weak self] task in
        self?.onDutyTask = task
        self?.isOnDuty = true
        self?.session?.deliveryTask = task
        self?.createTrackingSession()
        // we're not listening for incoming task for now
        self?.sessionListener?.remove()
      }
      .store(in: &subscriptions)
  }
  
  private func createTrackingSession() {
    guard let session = session,
          let location = currentLocation,
          let task = session.deliveryTask else { return }
    trackingRepository.createSession(with: session.courierId,
                                     deliveryTaskId: task.taskId,
                                     location: .init(coordinate: location.coordinate,
                                                     course: location.course))
  }
  
  private func updateTrackingSession(sessionId: String, location: CLLocation) {
    trackingRepository.updateSessionLocation(sessionId: sessionId,
                                             location: .init(coordinate: location.coordinate,
                                                             course: location.course))
  }
  
  private func listenForTask(courierId: String) {
    sessionListener = sessionRepository.listenerForSession(
      courierId: courierId,
      block: { [unowned self] snapshot, error in
        guard let snapshot = snapshot else { return }
        do {
          let session = try snapshot.data(as: CourierSession.self)
          if let deliveryTask = session.deliveryTask,
             deliveryTask.deadlineCourierConfirmation != nil {
            print("New delivery Task requested by: ID:\(deliveryTask.requesterId)NAME:\(deliveryTask.requesterName)")
            self.incomingTaskSubject.send(deliveryTask)
          }
        } catch {
          print("\nError listening for session: \(error) \n")
        }
            
      
      
      /*
      print("New delivery Task requested by: ID:\(deliveryTask.requesterId)NAME:\(deliveryTask.requesterName)")
      print("Rejecting in 10sec")
      DispatchQueue.main.asyncAfter(deadline: .now()+10) { [unowned self] in
        self.sessionRepository.rejectTask(courierId: courierId)
          .sink { completion in
            if case .failure(let error) = completion {
              print("failed rejecting task with error: \(error)")
            }
          } receiveValue: { _ in
            print("Task Rejected")
          }
          .store(in: &subscriptions)
      }
       */
    })
  }
  
  
}
