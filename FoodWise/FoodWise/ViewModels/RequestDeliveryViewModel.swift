//
//  RequestDeliveryViewModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 05/05/22.
//

import Foundation
import Combine
import CoreLocation
import MapKit

class RequestDeliveryViewModel: ObservableObject {
  @Published var showingCourierNotFoundError: Bool = false
  @Published var showingCourierFound: Bool = false
  @Published var totalDistance: Double? = nil
  @Published var totalTravelTime: Double? = nil
  
  @Published var isLookingForCourier = false {
    didSet {
      title = isLookingForCourier ? "Finding Courier..." : deliveryFeeTitle
    }
  }
  
  var totalDistanceText: String {
    guard let totalDistance = totalDistance else { return "..." }
    return String(format: "Total Distance: %.2f km", totalDistance)
  }
  var deliveryFeeTitle: String {
    return deliveryFee == nil ? "Calculating Delivery Fee..." : "Delivery Fee: \(deliveryFee!.asIndonesianCurrencyString())"
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
  private let donation: Donation
  private let mapRegionToPickUpSubject: PassthroughSubject<Void, Never> = .init()
  private let mapVisibleRectToInitialSubject: PassthroughSubject<Void, Never> = .init()
  private let deliveryTaskAssignedSubject: PassthroughSubject<DeliveryTask, Never> = .init()
  private var subscriptions: Set<AnyCancellable> = []
  
  private var deliveryFee: Double? = nil {
    didSet {
      if deliveryFee != nil { title = deliveryFeeTitle }
    }
  }
  
  var mapRegionToPickUpPublisher: AnyPublisher<Void, Never> {
    mapRegionToPickUpSubject.eraseToAnyPublisher()
  }
  var mapVisibleRectToInitialPublisher: AnyPublisher<Void, Never> {
    mapVisibleRectToInitialSubject.eraseToAnyPublisher()
  }
  var deliveryTaskAssignedPublisher: AnyPublisher<DeliveryTask, Never> {
    deliveryTaskAssignedSubject.eraseToAnyPublisher()
  }
  
  @Published private(set) var title: String = "Calculating Delivery Fee..."
  
  init(pickupGeoCooordinate: CLLocationCoordinate2D,
       destinationGeoCoordinate: CLLocationCoordinate2D,
       pickupAddress: String,
       pickupDetails: String,
       destinationAddress: String,
       destinationDetails: String,
       donation: Donation,
       repository: DeliveryTaskRepository = DeliveryTaskRepository()
  ) {
    self.pickupGeoCooordinate = pickupGeoCooordinate
    self.destinationGeoCoordinate = destinationGeoCoordinate
    self.pickupAddress = pickupAddress
    self.pickupDetails = pickupDetails
    self.destinationAddress = destinationAddress
    self.destinationDetails = destinationDetails
    self.donation = donation
    self.repository = repository
    fetchRoute()
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
  
  private func fetchRoute() {
    let origin = MKMapItem(placemark: .init(coordinate: pickupGeoCooordinate))
    let destination = MKMapItem(placemark: .init(coordinate: destinationGeoCoordinate))
    DirectionsCalculator().calculateRoute(from: origin, to: destination)
      .map { route in
        Measurement(value: route.distance, unit: UnitLength.meters).converted(to: .kilometers).value
      }
      .map { distance -> Double? in
        let firstRate = 1_500.00
        let secondRate = 2_500.00
        let thresholdDistance = Measurement(value: 5.0, unit: UnitLength.kilometers).value
        if distance > thresholdDistance {
          let afterFirstRate = (distance.truncatingRemainder(dividingBy: thresholdDistance)) * secondRate
          return firstRate * distance + afterFirstRate
        } else {
          return max(firstRate * distance, firstRate)
        }
      }
      .replaceError(with: nil)
      .assign(to: \.deliveryFee, on: self)
      .store(in: &subscriptions)
  }
  
  func requestDeliveryFor(requester: Customer) {
    guard let totalDistance = totalDistance,
          let totalTravelTime = totalTravelTime,
          let serviceWage = deliveryFee else {
      return
    }
    
    let destination = Address(location: destinationGeoCoordinate, geocodedLocation: destinationAddress, details: destinationDetails)
    
    var donationToBeDelivered = donation
    donationToBeDelivered.deliveryCharge = serviceWage
    donationToBeDelivered.shippingAddress = destination
    
    mapRegionToPickUpSubject.send(())
    isLookingForCourier = true
    let deliveryTask = DeliveryTask(pickupAddress: Address(location: pickupGeoCooordinate, geocodedLocation: pickupAddress, details: pickupDetails), dropOffAddress: destination, totalDistance: totalDistance, totalTravelTime: totalTravelTime, donation: donationToBeDelivered, serviceWage: serviceWage, requesterId: requester.id, requesterProfilePicUrl: requester.profileImageUrl?.absoluteString ?? "", requesterName: requester.fullName)
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

