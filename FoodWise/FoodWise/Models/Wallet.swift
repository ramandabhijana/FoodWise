//
//  Wallet.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 23/02/22.
//

import Foundation
import FirebaseFirestore

struct Wallet: Identifiable, Codable {
  let id: String
  var balance: Double
  var transactionHistory: [Transaction]
  let userId: String
}

struct Transaction: Identifiable, Codable {
  let id: String
  let dateTimestamp: Timestamp
  let amountSpent: Double
  let info: String
  
  init(date: Date, amountSpent: Double, info: String) {
    self.id = UUID().uuidString
    self.dateTimestamp = Timestamp(date: date)
    self.amountSpent = amountSpent
    self.info = info
  }
  
  var date: Date {
    dateTimestamp.dateValue()
  }
  
  var asObject: [String: Any] {
    [
      "id": id,
      "dateTimestamp": dateTimestamp,
      "amountSpent": amountSpent,
      "info": info
    ]
  }
  
  var calendarDate: Date {
    let dateComponents = Calendar.current.dateComponents(
      [.day, .month, .year],
      from: dateTimestamp.dateValue())
    let dateStringFormatter = DateFormatter()
    dateStringFormatter.dateFormat = "yyyy-MM-dd"
    let date = dateStringFormatter.date(from: "\(dateComponents.year!)-\(dateComponents.month!)-\(dateComponents.day!)")!
    return date
  }
}
