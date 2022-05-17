//
//  MapRoute.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 05/04/22.
//

import MapKit

struct MapRoute {
  let origin: MKMapItem
  let destination: MKMapItem
  
  var annotations: [MKAnnotation] {
    return [OriginAnnotation(item: origin),
            DestinationAnnotation(item: destination)]
  }
}

extension MapRoute {
  class OriginAnnotation: NSObject, MKAnnotation {
    private let item: MKMapItem
    
    var coordinate: CLLocationCoordinate2D { item.placemark.coordinate }
    
    init(item: MKMapItem) {
      self.item = item
      super.init()
    }
  }
}

extension MapRoute {
  class DestinationAnnotation: NSObject, MKAnnotation {
    private let item: MKMapItem
    
    var coordinate: CLLocationCoordinate2D { item.placemark.coordinate }
    
    init(item: MKMapItem) {
      self.item = item
      super.init()
    }
  }
}
