//
//  DrivingLicense.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 14/04/22.
//

import Foundation

struct DrivingLicense: Codable {
  var imageUrl: URL
  var licenseNo: String
  let licenseHolderId: String
}

extension DrivingLicense {
  init?(object: [String: Any]) {
    if let imageUrl = object["imageUrl"] as? String,
       let licenseNo = object["licenseNo"] as? String,
       let licenseHolderId = object["licenseHolderId"] as? String
    {
      self.init(imageUrl: URL(string: imageUrl)!,
                licenseNo: licenseNo,
                licenseHolderId: licenseHolderId)
    } else {
      print("\n🚨Fail to init mandatory field with object: \(object)\n")
      return nil
    }
  }
}
