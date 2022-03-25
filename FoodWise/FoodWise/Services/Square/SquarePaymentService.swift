//
//  SquarePaymentService.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 28/01/22.
//

import Foundation
import Combine

// Sandbox Application ID: sandbox-sq0idb-vJsWysuFEnnvTseBhZrQWw
// Sandbox access token: EAAAEErJ2peo8TIPfrejBsAvrkgdOzHytRa7IKLHXlvoOJUgVpZRYz7amhOqwQPH
// Location ID: LYP3M0120V5VB

enum SquareConstants {
  static let locationId = "LYP3M0120V5VB"
  static let applicationId = "sandbox-sq0idb-7w4Q56ba_7IQk4PYlbA8DA"
//  static let accessToken = "EAAAEErJ2peo8TIPfrejBsAvrkgdOzHytRa7IKLHXlvoOJUgVpZRYz7amhOqwQPH"
}

enum NetworkAPIError: Error {
  case requestFailed(Int)
  case postProcessingFailed(Error?)
}

class ChargePaymentService {
  private enum APIEnvironment: String {
    case prod = ""
    case localhost = "http://localhost:5000"
    
    var baseUrl: URL { URL(string: self.rawValue)! }
  }
  
  class func processWalletTopUp(_ body: WalletTopUpBody) -> AnyPublisher<Payment, Error> {
    let httpBody = try? JSONEncoder().encode(body)
    assert(httpBody != nil)
    let requestPath = "walletTopUp"
    let url = APIEnvironment.localhost.baseUrl.appendingPathComponent(requestPath)
    let urlRequest: URLRequest = {
      var req = URLRequest(url: url)
      req.httpMethod = "POST"
      req.addValue("Application/json", forHTTPHeaderField: "Content-Type")
      req.httpBody = httpBody!
      return req
    }()
    return URLSession.shared.dataTaskPublisher(for: urlRequest)
      .tryMap { data, response -> Data in
        guard
          let httpResponse = response as? HTTPURLResponse,
          200..<300 ~= httpResponse.statusCode
        else {
          let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
          throw NetworkAPIError.requestFailed(statusCode)
        }
        return data
      }
      .tryMap { data -> Payment in
        print(String(decoding: data, as: UTF8.self))
        return try JSONDecoder().decode(Payment.self, from: data)
      }
      .tryCatch { error -> AnyPublisher<Payment, NetworkAPIError> in
        throw NetworkAPIError.postProcessingFailed(error)
      }
      .receive(on: RunLoop.main)
      .eraseToAnyPublisher()
  }
}

// MARK: - Request Body
struct WalletTopUpBody: Encodable {
  let nonce: String
  let amount: Int
  let currency: String
  let name: String
  
  init(nonce: String, amount: Int, currency: String, userEmail: String) {
    self.nonce = nonce
    self.amount = amount
    self.currency = currency
    self.name = "TopUp-\(userEmail)"
  }
}

// MARK: - Response
struct Payment: Codable {
  let id, updatedAt: String
  let approvedMoney: Money
  let status: String
  let sourceType: String
  let cardDetails: CardDetails
  
  static private let jsonDateFormatter: DateFormatter = {
    let fmt = DateFormatter()
    let isoDateTimeMilliSec = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    fmt.dateFormat = isoDateTimeMilliSec
    return fmt
  }()
  static private let dateFormatter: DateFormatter = {
    let fmt = DateFormatter()
    fmt.dateFormat = "EEEE, d MMM yyyy"
    return fmt
  }()
  static private let timeFormatter: DateFormatter = {
    let fmt = DateFormatter()
    fmt.dateFormat = "HH:mm"
    return fmt
  }()
  
  var updatedAtDate: Date {
    return Self.jsonDateFormatter.date(from: updatedAt) ?? .now
  }
  
  enum CodingKeys: String, CodingKey {
    case id
    case updatedAt = "updated_at"
    case approvedMoney = "approved_money"
    case status
    case sourceType = "source_type"
    case cardDetails = "card_details"
  }
  
  var dateString: String {
    return Self.dateFormatter.string(from: updatedAtDate)
  }
  
  var timeString: String {
    return Self.timeFormatter.string(from: updatedAtDate)
  }
  
}

// MARK: - Money
struct Money: Codable {
  let amount: Int
  let currency: String
}

// MARK: - CardDetails
struct CardDetails: Codable {
  let status: String
  let card: Card
  let statementDescription: String
  
  enum CodingKeys: String, CodingKey {
    case status, card
    case statementDescription = "statement_description"
  }
}

// MARK: - Card
struct Card: Codable {
  let cardBrand, last4: String
  let cardType: String
  
  enum CodingKeys: String, CodingKey {
    case cardBrand = "card_brand"
    case last4 = "last_4"
    case cardType = "card_type"
  }
}
