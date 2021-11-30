//
//  AuthenticationService.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 30/11/21.
//

import Foundation
import FirebaseAuth

final class AuthenticationService {
  private let auth = Auth.auth()
  private var authenticationStateHandle: AuthStateDidChangeListenerHandle?
  
  public static let shared = AuthenticationService()
  
  private init() { }
  
  public var currentUserExist: Bool {
    auth.currentUser != nil
  }
  
  public var signedInUser: User? { auth.currentUser }
  
  public func signIn(
    email: String,
    password: String,
    completion: @escaping AuthDataResultCallback
  ) {
    auth.signIn(withEmail: email,
                password: password,
                completion: completion)
  }
  
  public func registerUser(
    withEmail email: String,
    password: String,
    completion: @escaping AuthDataResultCallback
  ) {
    auth.createUser(
      withEmail: email,
      password: password,
      completion: completion
    )
  }
  
  public func signOut() {
    do {
      print("signing out")
      try auth.signOut()
    } catch let signOutError as NSError {
      print("\nError signing out: %@\n", signOutError)
    }
  }
}
