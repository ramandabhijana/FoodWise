//
//  RemoveFoodViewModel.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 20/02/22.
//

import Foundation
import Combine

class RemoveFoodViewModel: ObservableObject {
  @Published var showingDeletionSuccessAlert: Bool = false
  @Published var showingDeletionConfirmationAlert: Bool = false
  @Published var deletionError: (shows: Bool, errorMessage: String) = (false, "")
  
  private let repository: FoodRepository
  private var foodSubject: PassthroughSubject<Food, Never> = .init()
  private var subscriptions: Set<AnyCancellable> = []
  
  private(set) var deleteConfirmationAlertTitle: String = ""
  
  var currentSelectedFood: Food? = nil {
    didSet {
      guard let name = currentSelectedFood?.name else { return }
      deleteConfirmationAlertTitle = "Are you sure to remove \"\(name)\"?"
    }
  }
  var foodDeletionPublisher: AnyPublisher<Food, Never> {
    foodSubject.eraseToAnyPublisher()
  }
  var deletionSuccessMessage: String {
    "Food was successfully removed"
  }
  var deletionConfirmationMessage: String {
    "Once this record is removed, you will no longer be able to manage the stock or edit the details of it.\nMake sure you are absolutely sure before confirming"
  }
  
  init(repository: FoodRepository) {
    self.repository = repository
  }
  
  
  func removeFood(_ food: Food) {
    Publishers.MergeMany(getPictureDataDeletionPublisher(for: food))
      .collect()
      .flatMap { [weak self] _ -> AnyPublisher<Void, Error> in
        guard let self = self else {
          return Fail(error: NSError()).eraseToAnyPublisher()
        }
        return self.repository.deleteFood(withId: food.id)
      }
      .subscribe(on: DispatchQueue.global(qos: .userInitiated))
      .receive(on: DispatchQueue.main)
      .sink(
        receiveCompletion: { [weak self] completion in
          if case .failure(let error) = completion {
            self?.deletionError = (shows: true, errorMessage: error.localizedDescription)
            return
          }
          self?.showingDeletionSuccessAlert = true
        },
        receiveValue: { [weak self] _ in
          guard let currentSelectedFood = self?.currentSelectedFood else {
            return
          }
          self?.foodSubject.send(currentSelectedFood)
        }
      )
      .store(in: &subscriptions)
  }
  
  private func getPictureDataDeletionPublisher(for food: Food) -> [AnyPublisher<Void, Error>] {
    let fileNames = food.imagesUrl.indices.map { "\(food.id)_\($0)" }
    var deletionPublishers: [AnyPublisher<Void, Error>] = []
    for fileName in fileNames {
      let publisher = StorageService.shared.deletePictureData(at: .foodPictures(fileName: fileName))
      deletionPublishers.append(publisher)
    }
    return deletionPublishers
  }
}
