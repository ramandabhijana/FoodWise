//
//  StorageManager.swift
//  
//
//  Created by Abhijana Agung Ramanda on 18/10/21.
//

import Foundation
import FirebaseStorage
import Combine

public final class StorageService {
  public static let shared = StorageService()
  private lazy var storage = Storage.storage().reference()
  
  private init() { }
  
  public func uploadPictureData(_ data: Data, path: Path) -> AnyPublisher<URL, Error> {
    Future { [weak self] promise in
      self?.storage.child(path.stringIdentifier)
        .putData(data, metadata: nil) { _, error in
          guard error == nil else {
            return promise(.failure(error!))
          }
          self?.storage.child(path.stringIdentifier)
            .downloadURL { url, error in
              guard error == nil, let url = url else {
                return promise(.failure(error!))
              }
              return promise(.success(url))
            }
        }
    }.eraseToAnyPublisher()
  }
  
  public func deletePicture(path: Path) async {
    do {
      try await storage.child(path.stringIdentifier).delete()
    } catch {
      // TODO: Add a more robust error handling
      print("Error deleting picture")
    }
  }
}

public extension StorageService {
  enum Path {
    case profilePictures(fileName: String)
    case chatPictures(fileName: String)
    case foodPictures(fileName: String)
    
    var stringIdentifier: String {
      switch self {
      case .profilePictures(let name):
        return "profile_pictures/\(name)"
      case .chatPictures(let name):
        return "chat_pictures/\(name)"
      case .foodPictures(let name):
        return "food_pictures/\(name)"
      }
    }
  }
}
