//
//  MapAnnotation.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 19/11/21.
//

import Foundation
import MapKit

class MapAnnotation: NSObject, FWAnnotation {
  var imageUrl: URL? { nil }
  var coordinate: CLLocationCoordinate2D
  
  init(coordinate: CLLocationCoordinate2D) {
    self.coordinate = coordinate
    super.init()
  }
}
