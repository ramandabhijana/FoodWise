//
//  RequestDeliveryViewModel.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 05/04/22.
//

import Foundation
import Combine
import CoreLocation

class RequestDeliveryViewModel: ObservableObject {
  @Published var showingCourierNotFoundError: Bool = false
  @Published var showingCourierFound: Bool = false
  @Published var totalDistance: Double? = nil
  @Published var totalTravelTime: Double? = nil
  @Published var isLookingForCourier = false {
    didSet {
      title = isLookingForCourier ? "Finding Courier..." : ""
    }
  }
  
  var totalDistanceText: String {
    guard let totalDistance = totalDistance else { return "..." }
    return String(format: "Total Distance: %.2f km", totalDistance)
  }
  var courierFoundText: String {
    "We've got a courier for you! 🙌🏼"
  }
  
  private(set) var pickupGeoCooordinate: CLLocationCoordinate2D
  private(set) var destinationGeoCoordinate: CLLocationCoordinate2D
  private(set) var pickupAddress: String
  private(set) var pickupDetails: String
  private(set) var destinationAddress: String
  private(set) var destinationDetails: String
  
  private var updatedDeliveryTask: DeliveryTask?
  private let repository: DeliveryTaskRepository
  private let order: Order
  private let mapRegionToPickUpSubject: PassthroughSubject<Void, Never> = .init()
  private let mapVisibleRectToInitialSubject: PassthroughSubject<Void, Never> = .init()
  private let deliveryTaskAssignedSubject: PassthroughSubject<DeliveryTask, Never> = .init()
  
  var mapRegionToPickUpPublisher: AnyPublisher<Void, Never> {
    mapRegionToPickUpSubject.eraseToAnyPublisher()
  }
  var mapVisibleRectToInitialPublisher: AnyPublisher<Void, Never> {
    mapVisibleRectToInitialSubject.eraseToAnyPublisher()
  }
  var deliveryTaskAssignedPublisher: AnyPublisher<DeliveryTask, Never> {
    deliveryTaskAssignedSubject.eraseToAnyPublisher()
  }
  
  @Published private(set) var title: String = ""
  
  init(pickupGeoCooordinate: CLLocationCoordinate2D,
       destinationGeoCoordinate: CLLocationCoordinate2D,
       pickupAddress: String,
       pickupDetails: String,
       destinationAddress: String,
       destinationDetails: String,
       order: Order,
       repository: DeliveryTaskRepository = DeliveryTaskRepository()
  ) {
    self.pickupGeoCooordinate = pickupGeoCooordinate
    self.destinationGeoCoordinate = destinationGeoCoordinate
    self.pickupAddress = pickupAddress
    self.pickupDetails = pickupDetails
    self.destinationAddress = destinationAddress
    self.destinationDetails = destinationDetails
    self.order = order
    self.repository = repository
  }
  
  deinit {
    mapVisibleRectToInitialSubject.send(completion: .finished)
    mapRegionToPickUpSubject.send(completion: .finished)
    deliveryTaskAssignedSubject.send(completion: .finished)
  }
  
  func centerVisibleMapRect() {
    mapVisibleRectToInitialSubject.send(())
  }
  
  func onDismissCourierFoundAlert() {
    guard let updatedDeliveryTask = updatedDeliveryTask else { return }
    deliveryTaskAssignedSubject.send(updatedDeliveryTask)
  }
  
  func requestDelivery(merchant: Merchant) {
    guard let totalDistance = totalDistance,
          let totalTravelTime = totalTravelTime else {
      return
    }
    mapRegionToPickUpSubject.send(())
    isLookingForCourier = true
    let deliveryTask = DeliveryTask(pickupAddress: ShippingAddress(location: pickupGeoCooordinate, geocodedLocation: pickupAddress, details: pickupDetails), dropOffAddress: ShippingAddress(location: destinationGeoCoordinate, geocodedLocation: destinationAddress, details: destinationDetails), totalDistance: totalDistance, totalTravelTime: totalTravelTime, order: order, requesterId: merchant.id, requesterProfilePicUrl: merchant.logoUrl?.absoluteString ?? "", requesterName: merchant.name)
    let radius3meters: Double = 3 * 1_000
    let pickupLocation = CLLocation(
      latitude: pickupGeoCooordinate.latitude,
      longitude: pickupGeoCooordinate.longitude)
    repository.assignTask(
      deliveryTask,
      toSessionWithinRadiusInM: radius3meters,
      centerLocation: pickupLocation) { [weak self] result in
        switch result {
        case .failure(let error):
          if let error = error as? CourierSessionError, error == .notAvailable {
            self?.showingCourierNotFoundError = true
            self?.isLookingForCourier = false
            self?.mapVisibleRectToInitialSubject.send(())
          }
        case .success(let updatedDeliveryTask):
          self?.isLookingForCourier = false
          self?.showingCourierFound = true
          self?.updatedDeliveryTask = updatedDeliveryTask
        }
      }
  }
}
