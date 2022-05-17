//
//  RouteMapView.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 09/04/22.
//

import MapKit
import SwiftUI
import Combine

struct RouteMapView: UIViewControllerRepresentable {
  private let route: MapRoute
  private let mapRegionToPickUpPublisher: AnyPublisher<Void, Never>?
  private let mapVisibleRectToInitialPublisher: AnyPublisher<Void, Never>?
  
  init(
    route: MapRoute,
    mapRegionToPickUpPublisher: AnyPublisher<Void, Never>? = nil,
    mapVisibleRectToInitialPublisher: AnyPublisher<Void, Never>? = nil
  ) {
    self.route = route
    self.mapRegionToPickUpPublisher = mapRegionToPickUpPublisher
    self.mapVisibleRectToInitialPublisher = mapVisibleRectToInitialPublisher
  }
  
  func makeUIViewController(context: Context) -> RouteMapViewController {
    let vc = RouteMapViewController(route: route,
                                    mapRegionToPickUpPublisher: mapRegionToPickUpPublisher,
                                    mapVisibleRectToInitialPublisher: mapVisibleRectToInitialPublisher)
    return vc
  }
  
  func updateUIViewController(_ uiViewController: RouteMapViewController, context: Context) {
    print("updateUIViewController")
  }
  
}
