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
  
  public var locationPublisher: AnyPublisher<CLLocation, Never> {
    locationSubject.eraseToAnyPublisher()
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
    if locationManager.authorizationStatus.isAuthorized {
      locationManager.startUpdatingLocation()
    }
  }
}

extension CLAuthorizationStatus {
  var isAuthorized: Bool {
    self == .authorizedAlways || self == .authorizedWhenInUse
  }
}
