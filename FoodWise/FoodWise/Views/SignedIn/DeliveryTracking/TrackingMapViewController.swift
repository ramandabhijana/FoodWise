//
//  TrackingMapViewController.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 15/04/22.
//

import UIKit
import MapKit
import Combine

class TrackingMapViewController: UIViewController {
  private let route: MapRoute
  private var courierAnnotation: CourierAnnotation
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
    map.register(
      CourierAnnotationView.self,
      forAnnotationViewWithReuseIdentifier: CourierAnnotationView.reuseIdentifier)
    map.isRotateEnabled = false
    map.pointOfInterestFilter = .init(including: [.amusementPark, .airport, .beach, .campground, .gasStation, .museum, .nationalPark, .park, .police])
    map.mapType = .mutedStandard
    return map
  }()
  
  init(
    route: MapRoute,
    courierAnnotation: CourierAnnotation,
    regionToCourierPublisher: AnyPublisher<Void, Never>
  ) {
    self.route = route
    self.courierAnnotation = courierAnnotation
    super.init(nibName: nil, bundle: nil)
    
    regionToCourierPublisher
      .sink { [weak self] _ in
        let courierRegion = MKCoordinateRegion(
          center: courierAnnotation.coordinate,
          span: .init(latitudeDelta: 0.005, longitudeDelta: 0.005))
        self?.mapView.setRegion(courierRegion, animated: true)
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
    
    let annotations = route.annotations + [courierAnnotation]
//    if let courierAnnotation = courierAnnotation {
//      annotations.append(courierAnnotation)
//    }
    mapView.addAnnotations(annotations)
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
//      self?.delegate?.didFinishFetchingRoute(with: mapRoute)
      self?.updateMapView(with: mapRoute)
    }
    .store(in: &subscriptions)
  }
  
  private func updateMapView(with route: MKRoute) {
    mapView.addOverlay(route.polyline)
    
    let polylineRect = route.polyline.boundingMapRect
    let visibleMapRect = mapView.visibleMapRect.union(polylineRect)
    mapView.setVisibleMapRect(visibleMapRect, animated: true)
  }
}

extension TrackingMapViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView,
               rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    let renderer = MKPolylineRenderer(overlay: overlay)
    renderer.strokeColor = UIColor(named: "AccentColor")
    renderer.lineWidth = 3
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
    case is CourierAnnotation:
      let identifier = CourierAnnotationView.reuseIdentifier
      let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation)
      return view
    default:
      return nil
    }
  }
}
