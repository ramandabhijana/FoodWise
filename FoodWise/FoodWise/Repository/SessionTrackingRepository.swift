//
//  SessionTrackingRepository.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 15/04/22.
//

import Foundation
import FirebaseDatabase
import CoreLocation

struct SessionTrackingRepository {
  let path: DatabaseReference = Database.database().reference(withPath: "sessions")
  var decoder: JSONDecoder = .init()
  
  func listenOnLocation(sesionId: String,
                        block: @escaping (LiveTrackSession) -> Void) -> UInt {
    return path.child(sesionId).observe(.value) { snapshot in
      guard let json = snapshot.value as? [String: Any] else {
        print("Snapshot value is not json: \(String(describing: snapshot.value))")
        return
      }
      do {
        let sessionData = try JSONSerialization.data(withJSONObject: json)
        let liveSession = try decoder.decode(LiveTrackSession.self, from: sessionData)
        block(liveSession)
      } catch {
        print("Error occurred", error)
      }
    }
  }
  
  func removeLocationListener(handle: UInt) {
    path.removeObserver(withHandle: handle)
  }
}

extension SessionTrackingRepository {
  struct LiveTrackSession: Codable {
    let sessionId: String
    let deliveryTaskId: String
    let location: Location
    
    var coordinate: CLLocationCoordinate2D {
      .init(latitude: location.latitude, longitude: location.longitude)
    }
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
    
  }
}
