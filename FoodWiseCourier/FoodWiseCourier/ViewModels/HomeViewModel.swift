//
//  HomeViewModel.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 16/03/22.
//

import Foundation
import Combine
import CoreLocation

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
  
  private let sessionRepository: CourierSessionRepository
  private let locationManager = LocationManager.shared
  private(set) var currentCoordinate: CLLocationCoordinate2D? = nil
  private var coordinateSubject: PassthroughSubject<CLLocationCoordinate2D, Never> = .init()
  private var session: CourierSession? = nil
  
  private var subscriptions: Set<AnyCancellable> = []
  
  var statusText: String { isOnline ? "ONLINE" : "OFFLINE" }
  var coordinatePublisher: AnyPublisher<CLLocationCoordinate2D, Never> {
    coordinateSubject.eraseToAnyPublisher()
  }
  
  let onlineInfoText = "We store your location to find you a customer"
  let offlineInfoText = "While in offline mode, we no longer store your location"
  
  init(sessionRepository: CourierSessionRepository = CourierSessionRepository()) {
    self.sessionRepository = sessionRepository
    locationManager.locationPublisher
      .sink { [weak self] clLocation in
        print(clLocation)
        self?.currentCoordinate = clLocation.coordinate
        self?.coordinateSubject.send(clLocation.coordinate)
        self?.coordinateSubject.send(completion: .finished)
        self?.updateSession()
      }
      .store(in: &subscriptions)
  }
  
  func createSession(courierId: String) {
    guard let currentCoordinate = currentCoordinate,
          session == nil else { return }
    
    sessionRepository.createSession(
      courierId: courierId,
      geoPoint: .init(latitude: currentCoordinate.latitude,
                      longitude: currentCoordinate.longitude)
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
  
  func updateSession() {
    guard
      let currentCoordinate = currentCoordinate,
      let session = session else { return }
    sessionRepository.updateSession(
      courierId: session.courierId,
      geoPoint: .init(latitude: currentCoordinate.latitude,
                      longitude: currentCoordinate.longitude)
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
      }
      .store(in: &subscriptions)
  }
  
  
  
  
}
