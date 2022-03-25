//
//  SMTPService.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 28/02/22.
//

import Foundation
import Combine

class SMTPService {
  private enum APIEnvironment: String {
    case prod = ""
    case localhost = "http://localhost:8080"
    
    var baseUrl: URL { URL(string: self.rawValue)! }
  }
  
  private enum Path: String {
    case adminWithdrawBalance = "admin/withdraw-wallet-balance"
    case userWithdrawBalance = "user/withdraw-wallet-balance"
    case acceptedAdoptionRequest = "accepted-adoption-request"
  }
  
  class func sendBalanceWithdrawalToAdmin(with data: WithdrawData) -> AnyPublisher<Void, Error> {
    let httpBody = try? JSONEncoder().encode(data)
    let path = Path.adminWithdrawBalance.rawValue
    let url = APIEnvironment.localhost.baseUrl.appendingPathComponent(path)
    let urlRequest: URLRequest = {
      var req = URLRequest(url: url)
      req.httpMethod = "POST"
      req.addValue("application/json", forHTTPHeaderField: "Content-Type")
      req.httpBody = httpBody!
      return req
    }()
    return makeDataTaskPublisher(for: urlRequest)
  }
  
  class func sendBalanceWithdrawalToUser(with data: WithdrawData) -> AnyPublisher<Void, Error> {
    let httpBody = try? JSONEncoder().encode(data)
    let path = Path.userWithdrawBalance.rawValue
    let url = APIEnvironment.localhost.baseUrl.appendingPathComponent(path)
    let urlRequest: URLRequest = {
      var req = URLRequest(url: url)
      req.httpMethod = "POST"
      req.addValue("application/json", forHTTPHeaderField: "Content-Type")
      req.httpBody = httpBody!
      return req
    }()
    return makeDataTaskPublisher(for: urlRequest)
  }
  
  class func sendAcceptedAdoptionRequest(data: AdoptionRequestAcceptedData) -> AnyPublisher<Void, Error> {
    let httpBody = try? JSONEncoder().encode(data)
    let path = Path.acceptedAdoptionRequest.rawValue
    let url = APIEnvironment.localhost.baseUrl.appendingPathComponent(path)
    let urlRequest: URLRequest = {
      var req = URLRequest(url: url)
      req.httpMethod = "POST"
      req.addValue("application/json", forHTTPHeaderField: "Content-Type")
      req.httpBody = httpBody!
      return req
    }()
    return makeDataTaskPublisher(for: urlRequest)
  }
  
  private class func makeDataTaskPublisher(for urlRequest: URLRequest) -> AnyPublisher<Void, Error> {
    URLSession.shared.dataTaskPublisher(for: urlRequest)
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
      .map { data -> Void in
//        print(String(decoding: data, as: UTF8.self))
//        return try JSONDecoder().decode(Payment.self, from: data)
        return ()
      }
      .receive(on: RunLoop.main)
      .eraseToAnyPublisher()
  }
}

struct WithdrawData: Encodable {
  let userEmail: String
  let userName: String
  let requestedAmount: String
  let bankName: String
  let accountNo: String
  let accountHolder: String
}

struct AdoptionRequestAcceptedData: Encodable {
  let userEmail: String
  let userName: String
  let requestSentDate: String
  let foodName: String
  let donorName: String
}
