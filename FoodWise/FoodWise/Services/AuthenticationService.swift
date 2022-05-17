//
//  AuthenticationService.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 27/11/21.
//

import Foundation
import Firebase
import GoogleSignIn
import Combine

final class AuthenticationService: ObservableObject {
  @Published public private(set) var user: User?
  
  private let auth = Auth.auth()
  private var authenticationStateHandle: AuthStateDidChangeListenerHandle?
  
  public static let shared = AuthenticationService()
  
  private init() {
    addListener()
  }
  
  private func addListener() {
    if let authenticationStateHandle = authenticationStateHandle {
      auth.removeStateDidChangeListener(authenticationStateHandle)
    }
    authenticationStateHandle = auth
      .addStateDidChangeListener { [unowned self] _, user in
        self.user = user
      }
  }
  
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
  
  func signInWithGoogle(onViewController viewController: UIViewController)
    -> AnyPublisher<(profile: GIDProfileData, authResult: AuthDataResult), Error>
  {
    guard let clientID = FirebaseApp.app()?.options.clientID else {
      fatalError("Missing clientID")
    }
    // Create Google Sign In configuration object.
    let config = GIDConfiguration(clientID: clientID)
    // Start the sign in flow!
    return Future { [unowned self] promise in
      GIDSignIn.sharedInstance.signIn(with: config, presenting: viewController) { user, error in
        guard
          error == nil,
          let idToken = user?.authentication.idToken,
          let accessToken = user?.authentication.accessToken,
          let profile = user?.profile
        else {
          return promise(.failure(error!))
        }
        let credential = GoogleAuthProvider.credential(
          withIDToken: idToken,
          accessToken: accessToken
        )
        self.auth.signIn(with: credential) { authResult, error in
          guard error == nil, let authResult = authResult else {
            return promise(.failure(error!))
          }
          return promise(.success((profile, authResult)))
        }
      }
    }.eraseToAnyPublisher()
  }
  
  public func signOut() {
    do {
//      precondition(currentUserExist)
      try auth.signOut()
    } catch let signOutError as NSError {
      print("\nError signing out: %@\n", signOutError)
    }
  }
}
