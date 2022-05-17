//
//  EditProfileViewModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 03/12/21.
//

import Foundation
import Combine

class EditProfileViewModel: ObservableObject {
  @Published var profileImageData: Data? = nil
  @Published var fullName: String
  
  @Published private(set) var nameValid = true
  @Published private(set) var errorMessage = ""
  @Published private(set) var savingUpdate = false
  
  private var rootViewModel: RootViewModel
  private var customer: Customer
  private let customerRepo = CustomerRepository()
  private var subscriptions = Set<AnyCancellable>()
  
  private var backgroundQueue = DispatchQueue(label: "EditProfileViewModel",
                                              qos: .userInitiated)
  
  public var buttonDisabled: Bool {
    !(nameValid && madeChanges)
  }
  
  init(rootViewModel: RootViewModel) {
    self.rootViewModel = rootViewModel
    self.customer = rootViewModel.customer!
    self.fullName = rootViewModel.customer?.fullName ?? ""
  }
  
  func saveChanges() {
    precondition(madeChanges)
    savingUpdate = true
    guard let profileImageData = profileImageData else {
      updateCustomer()
      return
    }
    StorageService.shared.uploadPictureData(
      profileImageData,
      path: .profilePictures(fileName: customer.id)
    )
      .subscribe(on: backgroundQueue)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] completion in
        if case .failure(let error) = completion {
          self?.errorMessage = error.localizedDescription
        }
        self?.savingUpdate = false
      } receiveValue: { [weak self] url in
        self?.customer.profileImageUrl = url
        self?.updateCustomer()
      }
      .store(in: &subscriptions)
  }
  
  private func updateCustomer() {
    customer.fullName = fullName
    customerRepo.updateCustomerProfile(
      customerId: customer.id,
      fullName: customer.fullName
    )
      .subscribe(on: backgroundQueue)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] completion in
        if case .failure(let error) = completion {
          self?.errorMessage = error.localizedDescription
        }
        self?.savingUpdate = false
      } receiveValue: { [weak self] _ in
        guard let self = self else { return }
        self.rootViewModel.setCustomer(self.customer)
      }
      .store(in: &subscriptions)
  }
  
  private var madeChanges: Bool {
    (rootViewModel.customer?.fullName != fullName)
    || (profileImageData != nil)
  }
  
  func validateNameIfFocusIsLost(_ focus: Bool) {
    guard focus == false else { return }
    nameValid = !fullName.isEmpty
  }
}
