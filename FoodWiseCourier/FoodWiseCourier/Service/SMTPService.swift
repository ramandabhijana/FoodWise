//
//  SMTPService.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 15/05/22.
//

import Foundation
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
    case rejectionRemark = "rejection-remark"
    case acceptedRemark = "accepted-remark"
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
  
  class func sendOrderRemark(with data: OrderRemarkData, accepted: Bool) -> AnyPublisher<Void, Error> {
    let httpBody = try? JSONEncoder().encode(data)
    let path = (accepted ? Path.acceptedRemark : .rejectionRemark).rawValue
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

enum NetworkAPIError: Error {
  case requestFailed(Int)
  case postProcessingFailed(Error?)
}

struct WithdrawData: Encodable {
  let userEmail: String
  let userName: String
  let requestedAmount: String
  let bankName: String
  let accountNo: String
  let accountHolder: String
}

struct OrderRemarkData: Encodable {
  let userEmail: String
  let userName: String
  let date: String
  let time: String
  let merchantName: String
  let remarks: String
}
