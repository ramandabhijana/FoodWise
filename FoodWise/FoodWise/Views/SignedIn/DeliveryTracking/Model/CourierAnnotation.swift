//
//  CourierAnnotation.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 15/04/22.
//

import Foundation
import MapKit

final class CourierAnnotation: NSObject, MKAnnotation {
  @objc dynamic var coordinate: CLLocationCoordinate2D
  @objc dynamic var course: Double
  
  init(latitude: Double, longitude: Double, course: Double) {
    self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    self.course = course
  }
}
