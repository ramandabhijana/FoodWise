//
//  NearbyMapViewModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 10/12/21.
//

import Foundation
import MapKit
import Combine

class NearbyMapViewModel: ObservableObject {
  @Published private(set) var region: MKCoordinateRegion?
  @Published private(set) var nearbyMerchants: NearbyMerchants? = nil
  @Published var currentSelectedRadiusIndex = 0
  
  private let locationManager = LocationManager.shared
  private var radiusChangedSubject: PassthroughSubject<NearbyRadius, Never>
  private var subscriptions = Set<AnyCancellable>()
  
  init(radiusChangedSubject: PassthroughSubject<NearbyRadius, Never>,
       filteredMerchantsPublisher: AnyPublisher<[NearbyMerchants], Never>
  ) {
    self.radiusChangedSubject = radiusChangedSubject
    
    locationManager.startMonitoring()
    locationManager.locationPublisher
      .sink { [weak self] _ in
        self?.locationManager.stopLocationService()
      } receiveValue: { [weak self] userLocation in
        self?.region = .init(
          center: userLocation.coordinate,
          span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
      }
      .store(in: &subscriptions)
    
    filteredMerchantsPublisher
      .sink { [weak self] merchants in
        var nearbyMerchants = NearbyMerchants(radius: merchants.last!.radius)
        nearbyMerchants.merchants = merchants.reduce([]) { $0 + $1.merchants }
        self?.nearbyMerchants = nearbyMerchants
      }
      .store(in: &subscriptions)
  }
  
  deinit {
    print("NearbyMapViewModel deinitialized")
  }

  func onChangeRadius(_ radius: NearbyRadius) {
    radiusChangedSubject.send(radius)
    region?.span = spanForRadius(radius)
  }
  
  private func spanForRadius(_ radius: NearbyRadius) -> MKCoordinateSpan {
    switch radius {
    case .oneKm:
      return .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
    case .threeKm:
      return .init(latitudeDelta: 0.05, longitudeDelta: 0.05)
    case .fiveKm:
      return .init(latitudeDelta: 0.1, longitudeDelta: 0.1)
    case .sevenKm:
      return .init(latitudeDelta: 0.25, longitudeDelta: 0.25)
    }
  }
}
