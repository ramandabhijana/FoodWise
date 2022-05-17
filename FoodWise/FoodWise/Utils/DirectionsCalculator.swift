//
//  DirectionsCalculator.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 05/04/22.
//

import MapKit
import Combine

struct DirectionsCalculator {
  
  func calculateRoute(
    from origin: MKMapItem,
    to destination: MKMapItem) -> AnyPublisher<MKRoute, Error>
  {
    return Future { promise in
      let directionsRequest: MKDirections.Request = {
        let req = MKDirections.Request()
        req.source = origin
        req.destination = destination
        return req
      }()
      let directions = MKDirections(request: directionsRequest)
      directions.calculate { response, error in
        if let error = error {
          return promise(.failure(error))
        }
        guard let mapRoute = response?.routes.first else {
          print("Route not found")
          return promise(.failure(NSError()))
        }
        return promise(.success(mapRoute))
      }
    }
    .eraseToAnyPublisher()
  }
  
  
}
