//
//  Courier.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 30/11/21.
//

import Foundation

struct Courier: Codable {
  let id: String
  var name: String
  var bikeBrand: String
  var bikePlate: String
  let email: String
  var license: DrivingLicense
  var profilePictureUrl: URL? = nil
}

extension Courier {
//  init?(object: [String: Any]) {
//    if let id = object["id"] as? String,
//       let name = object["name"] as? String,
//       let bikeBrand = object["bikeBrand"] as? String,
//       let bikePlate = object["bikePlate"] as? String,
//       let licenseObject = object["license"] as? [String: Any],
//       let license = DrivingLicense(object: licenseObject),
//       let email = object["email"] as? String
//    {
//      self.init(
//        id: id,
//        name: name,
//        bikeBrand: bikeBrand,
//        bikePlate: bikePlate,
//        email: email,
//        license: license
//      )
//      guard let profilePictureUrl = object["profilePictureUrl"] as? String else {
//        return
//      }
//      self.profilePictureUrl = URL(string: profilePictureUrl)
//    } else {
//      print("\n🚨Fail to init mandatory field with object: \(object)\n")
//      return nil
//    }
//  }
}
