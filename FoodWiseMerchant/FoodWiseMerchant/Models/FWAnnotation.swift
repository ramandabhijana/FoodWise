//
//  FWAnnotation.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 19/11/21.
//

import MapKit

protocol FWAnnotation: MKAnnotation {
  var imageUrl: URL? { get }
}
