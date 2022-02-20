//
//  LocationManager.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 19/11/21.
//

import Foundation
import MapKit
import Combine

final class LocationManager: NSObject {
  private lazy var locationManager = CLLocationManager()
  private var locationSubject = PassthroughSubject<CLLocation, Never>()
  private var authStatusSubject = PassthroughSubject<CLAuthorizationStatus, Never>()
  
  public var locationPublisher: AnyPublisher<CLLocation, Never> {
    locationSubject.eraseToAnyPublisher()
  }
  public var authStatusPublisher: AnyPublisher<CLAuthorizationStatus, Never> {
    authStatusSubject.eraseToAnyPublisher()
  }
  
  public static let shared = LocationManager()
  
  private override init() {
    super.init()
    locationManager.requestWhenInUseAuthorization()
    locationManager.delegate = self
  }
  
  func startMonitoring() {
    locationManager.startUpdatingLocation()
  }
  
  func stopLocationService() {
    locationManager.stopUpdatingLocation()
  }
  
  func requestLocationAuthorization() {
    locationManager.requestWhenInUseAuthorization()
  }
}

extension LocationManager: CLLocationManagerDelegate {
  func locationManager(
    _ manager: CLLocationManager,
    didUpdateLocations locations: [CLLocation]
  ) {
    guard let latestLocation = locations.first else { return }
    locationSubject.send(latestLocation)
  }
  
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    authStatusSubject.send(manager.authorizationStatus)
  }
}

extension CLAuthorizationStatus {
  var isAuthorized: Bool {
    self == .authorizedAlways || self == .authorizedWhenInUse
  }
}
