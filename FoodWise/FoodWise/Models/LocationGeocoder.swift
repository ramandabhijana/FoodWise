//
//  LocationGeocoder.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 20/11/21.
//

import Foundation
import CoreLocation

final class Geocoder: NSObject {
  private lazy var geocoder = CLGeocoder()
  
  public static let shared = Geocoder()
  
  private override init() { }
  
  public func reverseGeocode(location: CLLocation) async throws -> String {
    let placemarks = try await geocoder.reverseGeocodeLocation(location)
    guard let placemark = placemarks.first else { throw GeocodingError.missingPlacemark }
    if let city = placemark.locality,
       let state = placemark.administrativeArea
    {
      let streetNumber = placemark.subThoroughfare?.appending(" ") ?? ""
      let street = placemark.thoroughfare?.appending(" ") ?? ""
      return "\(streetNumber)\(street)\(city), \(state)"
    }
    throw GeocodingError.addressUnknown
  }
  
  public func forwardGeocode(addressString string: String) async throws -> CLLocation {
    let placemarks = try await geocoder.geocodeAddressString(string)
    guard let placemark = placemarks.first else { throw GeocodingError.missingPlacemark }
    if let location = placemark.location {
      return location
    }
    throw GeocodingError.locationUnknown
  }
}

enum GeocodingError: String, Error {
  case missingPlacemark = "Placemark is not found"
  case addressUnknown = "Address Unknown"
  case locationUnknown = "Location Unknown"
}
