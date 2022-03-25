//
//  SelectLocationViewModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 08/03/22.
//

import Foundation
import Combine
import MapKit
import CoreLocation

class SelectLocationViewModel: ObservableObject {
  @Published public private(set) var region: MKCoordinateRegion? = nil
  @Published public private(set) var geocodedLocation = ""
  @Published internal var addressDetails = ""
  @Published internal var coordinate: CLLocationCoordinate2D? {
    didSet {
      print("coordinate was set: \(String(describing: coordinate))")
      guard let coordinate = coordinate else {
        coordinateIsSet = false
        return
      }
      coordinateIsSet = true
      Task { await geocodeLocation(coordinate: coordinate) }
    }
  }
  @Published private(set) var coordinateIsSet = false
  
  private var userLocationSubscription: AnyCancellable? = nil
  
  init(coordinate: CLLocationCoordinate2D? = nil, addressDetails: String? = nil) {
    self.coordinate = coordinate
    self.addressDetails = addressDetails ?? ""
    if let coordinate = coordinate {
      self.region = MKCoordinateRegion(center: coordinate, span: span)
    }
  }
  
  func fetchUserLocation() {
    print("Fetching location")
    LocationManager.shared.startMonitoring()
    userLocationSubscription = LocationManager.shared.locationPublisher
      .sink { [weak self] location in
        guard let self = self else { return }
        print("Received location: \(location)")
        self.region = MKCoordinateRegion(center: location.coordinate,
                                         span: span)
        LocationManager.shared.stopLocationService()
      }
  }
  
  @MainActor
  private func geocodeLocation(coordinate: CLLocationCoordinate2D) async {
    do {
      let location = CLLocation(latitude: coordinate.latitude,
                                longitude: coordinate.longitude)
      geocodedLocation = try await Geocoder.shared.reverseGeocode(location: location)
    } catch let error as GeocodingError {
      geocodedLocation = error.rawValue
    } catch {
      print(error)
    }
  }
  
  func resetCoordinate() {
    coordinate = nil
    addressDetails = ""
  }
}

fileprivate let span = MKCoordinateSpan(latitudeDelta: 0.005,
                                        longitudeDelta: 0.005)
