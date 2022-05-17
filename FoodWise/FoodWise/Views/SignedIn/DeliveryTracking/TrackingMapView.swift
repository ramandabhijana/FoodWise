//
//  TrackingMapView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 15/04/22.
//

import MapKit
import SwiftUI
import Combine

struct TrackingMapView: UIViewControllerRepresentable {
  typealias UIViewControllerType = TrackingMapViewController
  
  private let route: MapRoute
  private var courierAnnotation: CourierAnnotation
  private let regionToCourierPublisher: AnyPublisher<Void, Never>
  
  init(route: MapRoute,
       courierAnnotation: CourierAnnotation,
       regionToCourierPublisher: AnyPublisher<Void, Never>) {
    self.route = route
    self.courierAnnotation = courierAnnotation
    self.regionToCourierPublisher = regionToCourierPublisher
  }
  
  func makeUIViewController(context: Context) -> TrackingMapViewController {
    let vc = TrackingMapViewController(route: route, courierAnnotation: courierAnnotation, regionToCourierPublisher: regionToCourierPublisher)
    return vc
  }
  
  func updateUIViewController(_ uiViewController: TrackingMapViewController, context: Context) {
    print("\nupdateUIViewController called\n")
  }
}
