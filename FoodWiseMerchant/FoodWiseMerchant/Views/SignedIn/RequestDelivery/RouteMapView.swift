//
//  RouteMapView.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 05/04/22.
//

import MapKit
import SwiftUI
import Combine

struct RouteMapView: UIViewControllerRepresentable {
  @Binding private var totalDistance: Double?
  @Binding private var totalTravelTime: Double?
  
  private let route: MapRoute
  private let mapRegionToPickUpPublisher: AnyPublisher<Void, Never>
  private let mapVisibleRectToInitialPublisher: AnyPublisher<Void, Never>
  
  init(
    totalDistance: Binding<Double?>,
    totalTravelTime: Binding<Double?>,
    route: MapRoute,
    mapRegionToPickUpPublisher: AnyPublisher<Void, Never>,
    mapVisibleRectToInitialPublisher: AnyPublisher<Void, Never>
  ) {
    _totalDistance = totalDistance
    _totalTravelTime = totalTravelTime
    self.route = route
    self.mapRegionToPickUpPublisher = mapRegionToPickUpPublisher
    self.mapVisibleRectToInitialPublisher = mapVisibleRectToInitialPublisher
  }
  
  func makeUIViewController(context: Context) -> RouteMapViewController {
    let vc = RouteMapViewController(route: route,
                                    mapRegionToPickUpPublisher: mapRegionToPickUpPublisher,
                                    mapVisibleRectToInitialPublisher: mapVisibleRectToInitialPublisher)
    vc.delegate = context.coordinator
    return vc
  }
  
  func updateUIViewController(_ uiViewController: RouteMapViewController, context: Context) {
    print("updateUIViewController")
  }
  
  func makeCoordinator() -> some RouteMapViewControllerDelegate {
    RouteMapView.Delegate(totalDistance: $totalDistance,
                          totalTravelTime: $totalTravelTime)
  }
  
}

private extension RouteMapView {
  final class Delegate: RouteMapViewControllerDelegate {
    @Binding private var totalDistance: Double?
    @Binding private var totalTravelTime: Double?
    
    init(
      totalDistance: Binding<Double?>,
      totalTravelTime: Binding<Double?>
    ) {
      _totalDistance = totalDistance
      _totalTravelTime = totalTravelTime
    }
    
    func didFinishFetchingRoute(with route: MKRoute) {
      let distanceInMeters = Measurement(value: route.distance, unit: UnitLength.meters)
      let distanceInKilometers = distanceInMeters.converted(to: .kilometers)
      totalDistance = distanceInKilometers.value
      totalTravelTime = route.expectedTravelTime
    }
  }
}
