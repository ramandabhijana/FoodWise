//
//  MKMapView+Common.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 05/11/21.
//

import SwiftUI
import MapKit

extension MKMapView {
  func commonSetup() {
    self.register(
      FWAnnotationView.self,
      forAnnotationViewWithReuseIdentifier: FWAnnotationView.reuseIdentifier
    )
    self.register(
      FWClusterAnnotationView.self,
      forAnnotationViewWithReuseIdentifier: FWClusterAnnotationView.reuseIdentifier
    )
    let filters = MKPointOfInterestFilter(including: [])
    self.pointOfInterestFilter = .some(filters)
    self.isRotateEnabled = false
    self.showsUserLocation = true
  }
}

extension MKMapViewDelegate {
  func commonAnnotationViewSetup(
    mapView: MKMapView,
    annotation: MKAnnotation
  ) -> MKAnnotationView? {
    switch annotation {
    case is FWAnnotation:
      let identifier = FWAnnotationView.reuseIdentifier
      let view = mapView.dequeueReusableAnnotationView(
        withIdentifier: identifier,
        for: annotation
      )
      return view
    case is MKClusterAnnotation:
      let identifier = FWClusterAnnotationView.reuseIdentifier
      let view = mapView.dequeueReusableAnnotationView(
        withIdentifier: identifier,
        for: annotation
      )
      return view
//    case is MKUserLocation:
//      let annotationView = MKAnnotationView()
//      annotationView.canShowCallout = false
//      annotationView.isUserInteractionEnabled = false
//      return annotationView
    default:
      return nil
    }
  }
}
