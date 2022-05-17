//
//  RouteMapViewController.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 05/04/22.
//

import MapKit
import UIKit
import Combine
import SwiftUI

protocol RouteMapViewControllerDelegate: AnyObject {
  func didFinishFetchingRoute(with route: MKRoute)
  
}

class RouteMapViewController: UIViewController {
  private let route: MapRoute
  private var initialVisibleMapRect: MKMapRect? = nil
  private var directionsCalculator: DirectionsCalculator = .init()
  private var subscriptions: Set<AnyCancellable> = []
  
  private let mapView: MKMapView = {
    let map = MKMapView()
    map.register(
      FWOriginAnnotationView.self,
      forAnnotationViewWithReuseIdentifier: FWOriginAnnotationView.reuseIdentifier)
    map.register(
      FWDestinationAnnotationView.self,
      forAnnotationViewWithReuseIdentifier: FWDestinationAnnotationView.reuseIdentifier)
    map.isRotateEnabled = false
    map.mapType = .mutedStandard
    return map
  }()
  
  weak var delegate: RouteMapViewControllerDelegate?
  
  init(
    route: MapRoute,
    mapRegionToPickUpPublisher: AnyPublisher<Void, Never>,
    mapVisibleRectToInitialPublisher: AnyPublisher<Void, Never>
  ) {
    self.route = route
    super.init(nibName: nil, bundle: nil)
    
    mapRegionToPickUpPublisher.sink { [weak self] _ in
      let region = MKCoordinateRegion(
        center: route.origin.placemark.coordinate,
        span: .init(latitudeDelta: 0.001, longitudeDelta: 0.001)
      )
      self?.mapView.setRegion(region, animated: true)
      self?.mapView.isUserInteractionEnabled = false
    }
    .store(in: &subscriptions)
    
    mapVisibleRectToInitialPublisher.sink { [weak self] _ in
      guard let initialVisibleMapRect = self?.initialVisibleMapRect else {
        return
      }
      self?.mapView.isUserInteractionEnabled = true
      self?.mapView.setVisibleMapRect(initialVisibleMapRect, animated: true)
    }
    .store(in: &subscriptions)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    fetchRoute()
    view.addSubview(mapView)
    mapView.delegate = self
    mapView.showAnnotations(route.annotations, animated: false)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    mapView.frame = view.bounds
  }
  
  private func fetchRoute() {
    directionsCalculator.calculateRoute(
      from: route.origin,
      to: route.destination
    ).sink { completion in
      if case .failure(let error) = completion {
        print("Failed getting route calculation result: \(error)")
      }
    } receiveValue: { [weak self] mapRoute in
      self?.delegate?.didFinishFetchingRoute(with: mapRoute)
      self?.updateMapView(with: mapRoute)
    }
    .store(in: &subscriptions)
    /*
    let directionsRequest: MKDirections.Request = {
      let req = MKDirections.Request()
      req.source = route.origin
      req.destination = route.destination
      return req
    }()
    let directions = MKDirections(request: directionsRequest)
    directions.calculate { [weak self] response, error in
      guard let mapRoute = response?.routes.first else {
        print(error?.localizedDescription ?? "Route is not available")
        return
      }
      self?.delegate?.didFinishFetchingRoute(with: mapRoute)
      self?.updateMapView(with: mapRoute)
    }
    */
  }
  
  private func updateMapView(with route: MKRoute) {
    mapView.addOverlay(route.polyline)
    
    let polylineRect = route.polyline.boundingMapRect
    let visibleMapRect = mapView.visibleMapRect.union(polylineRect)
    initialVisibleMapRect = visibleMapRect
    mapView.setVisibleMapRect(visibleMapRect, animated: true)
  }
}

extension RouteMapViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView,
               rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    let renderer = MKPolylineRenderer(overlay: overlay)
    renderer.strokeColor = UIColor(named: "AccentColor")
    renderer.lineWidth = 5
    
    return renderer
  }
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    switch annotation {
    case is MapRoute.OriginAnnotation:
      let identifier = FWOriginAnnotationView.reuseIdentifier
      let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation)
      return view
    case is MapRoute.DestinationAnnotation:
      let identifier = FWDestinationAnnotationView.reuseIdentifier
      let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation)
      return view
    default:
      return nil
    }
  }
}
