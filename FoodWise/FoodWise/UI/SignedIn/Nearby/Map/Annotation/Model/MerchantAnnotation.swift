//
//  MerchantAnnotation.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 05/11/21.
//

import MapKit

struct Merchant: Identifiable {
  let id = UUID()
  let logoUrl: URL?
  let name: String
  let coordinate: (lat: Double, long: Double)
}

class MerchantAnnotation: NSObject, FWAnnotation {
  private(set) var merchant: Merchant
  
  var coordinate: CLLocationCoordinate2D {
    .init(latitude: merchant.coordinate.lat,
          longitude: merchant.coordinate.long)
  }
  
  var imageUrl: URL? { merchant.logoUrl }
  
  init(merchant: Merchant) {
    self.merchant = merchant
    super.init()
  }
}
