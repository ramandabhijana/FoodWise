//
//  EditProfileViewModel.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 01/12/21.
//

import Foundation
import Combine

class EditProfileViewModel: ObservableObject {
  @Published var profileImageData: Data? = nil
  @Published var name: String
  @Published var storeType: String
  var address: (location: MerchantLocation, details: String)?
  
  @Published private(set) var nameValid = true
  @Published private(set) var storeTypeValid = true
  @Published private(set) var addressValid = true
  
  @Published private(set) var errorMessage = ""
  @Published private(set) var savingUpdate = false

  private var mainViewModel: MainViewModel
  private let merchantRepo = MerchantRepository()
  private var subscriptions = Set<AnyCancellable>()
  
  public var buttonDisabled: Bool {
    !(nameValid && storeTypeValid && addressValid && madeChanges)
  }
  
  init(mainViewModel: MainViewModel) {
    let merchant = mainViewModel.merchant
    self.mainViewModel = mainViewModel
    self.name = merchant?.name ?? ""
    self.storeType = merchant?.storeType ?? ""
    if let location = merchant?.location,
       let details = merchant?.addressDetails {
      self.address = (location, details)
    }
  }
  
  func saveChanges() {
    precondition(addressValid)
    savingUpdate = true
    if let imageData = profileImageData {
      updateImageChanged(imageData: imageData)
    } else {
      merchantRepo.updateMerchant(
        merchantId: mainViewModel.merchant.id,
        logoUrl: nil,
        name: name,
        storeType: storeType,
        location: address!.location,
        addressDetails: (address?.details) ?? ""
      )
      .sink { [weak self] completion in
        if case .failure(let error) = completion {
          self?.errorMessage = error.localizedDescription
          self?.savingUpdate = false
        }
      } receiveValue: { [weak self] merchant in
        self?.mainViewModel.setMerchant(merchant)
        self?.savingUpdate = false
      }
      .store(in: &subscriptions)
    }
  }
  
  private func updateImageChanged(imageData: Data) {
    StorageService.shared.uploadPictureData(
      imageData,
      path: .profilePictures(fileName: mainViewModel.merchant.id)
    )
    .flatMap { [unowned self] url in
      merchantRepo.updateMerchant(
        merchantId: mainViewModel.merchant.id,
        logoUrl: url,
        name: name,
        storeType: storeType,
        location: address!.location,
        addressDetails: (address?.details) ?? ""
      )
    }
    .sink { [weak self] completion in
      if case .failure(let error) = completion {
        self?.errorMessage = error.localizedDescription
        self?.savingUpdate = false
      }
    } receiveValue: { [weak self] merchant in
      self?.mainViewModel.setMerchant(merchant)
      self?.savingUpdate = false
    }
    .store(in: &subscriptions)
  }
  
  func validateNameIfFocusIsLost(_ focus: Bool) {
    guard focus == false else { return }
    nameValid = !name.isEmpty
  }
  
  func validateStoreTypeIfFocusIsLost(_ focus: Bool) {
    guard focus == false else { return }
    storeTypeValid = !storeType.isEmpty
  }
  
  func validateAddressIfFocusIsLost(focus: Bool) {
    guard focus == false else { return }
    addressValid = address != nil
  }
  
  private var madeChanges: Bool {
    (mainViewModel.merchant.name != name)
    || (mainViewModel.merchant.storeType != storeType)
    || (mainViewModel.merchant.location != address?.location)
    || (mainViewModel.merchant.addressDetails != address?.details)
    || (profileImageData != nil)
  }
}
