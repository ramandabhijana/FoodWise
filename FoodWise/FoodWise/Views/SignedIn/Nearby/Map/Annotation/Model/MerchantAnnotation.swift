//
//  MerchantAnnotation.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 05/11/21.
//

import MapKit

class MerchantAnnotation: NSObject, FWAnnotation {
  private(set) var merchant: Merchant
  
  var coordinate: CLLocationCoordinate2D {
    .init(latitude: merchant.location.lat,
          longitude: merchant.location.long)
  }
  
  var imageUrl: URL? { merchant.logoUrl }
  
  init(merchant: Merchant) {
    self.merchant = merchant
    super.init()
  }
}
