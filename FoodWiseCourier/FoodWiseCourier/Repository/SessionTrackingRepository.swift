//
//  SessionTrackingRepository.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 11/04/22.
//

import Foundation
import FirebaseDatabase
import CoreLocation

struct SessionTrackingRepository {
  let path: DatabaseReference = Database.database().reference(withPath: "sessions")
  
  func createSession(with sessionId: String, deliveryTaskId: String, location: Location) {
    let newSession = LiveTrackSession(sessionId: sessionId,
                                      deliveryTaskId: deliveryTaskId,
                                      location: location)
    do {
      let data = try JSONEncoder().encode(newSession)
      let json = try JSONSerialization.jsonObject(with: data)
      path.child(sessionId).setValue(json)
    } catch {
      fatalError("error occurred \(error)")
    }
  }
  
  func updateSessionLocation(sessionId: String, location: Location) {
    do {
      let data = try JSONEncoder().encode(location)
      let json = try JSONSerialization.jsonObject(with: data)
      path.child(sessionId).child("location").setValue(json)
    } catch {
      fatalError("error occurred \(error)")
    }
  }
  
  func deleteSession(sessionId: String) {
    path.child(sessionId).removeValue()
  }
}

extension SessionTrackingRepository {
  struct LiveTrackSession: Codable {
    let sessionId: String
    let deliveryTaskId: String
    let location: Location
  }
  
  struct Location: Codable {
    let latitude: Double
    let longitude: Double
    let course: Double
    
    init(coordinate: CLLocationCoordinate2D, course: Double) {
      self.latitude = coordinate.latitude
      self.longitude = coordinate.longitude
      self.course = course
    }
    
    var asClLocation: CLLocation {
      CLLocation(latitude: latitude, longitude: longitude)
    }
  }
}
