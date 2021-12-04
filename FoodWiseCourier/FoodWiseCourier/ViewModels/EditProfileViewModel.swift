//
//  EditProfileViewModel.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 02/12/21.
//

import Foundation
import Combine

class EditProfileViewModel: ObservableObject {
  
  private enum ImageUploadKind {
    case profile, license
  }
  
  @Published var profileImageData: Data? = nil
  @Published var fullName: String
  @Published var bikeBrand: String
  @Published var bikePlate: String
  
  var license: (imageData: Data?, licenseNo: String)
  
  @Published private(set) var nameValid = true
  @Published private(set) var bikeBrandValid = true
  @Published private(set) var bikePlateValid = true
  @Published private(set) var licenseValid = true
  
  @Published private(set) var errorMessage = ""
  @Published private(set) var savingUpdate = false
  
  private var mainViewModel: MainViewModel
  private let courierRepo = CourierRepository()
  private var subscriptions = Set<AnyCancellable>()
  private var courier: Courier
  
  public var buttonDisabled: Bool {
    !(nameValid && bikeBrandValid && bikePlateValid && madeChanges)
  }
  
  private var queue = DispatchQueue(label: "EditProfileViewModel",
                                    qos: .userInitiated)
  
  init(mainViewModel: MainViewModel) {
    let courier = mainViewModel.courier
    self.courier = courier!
    self.mainViewModel = mainViewModel
    self.fullName = courier?.name ?? ""
    self.bikePlate = courier?.bikePlate ?? ""
    self.bikeBrand = courier?.bikeBrand ?? ""
    self.license = (nil, mainViewModel.courier.license.licenseNo)
  }
  
  func saveChanges() {
    precondition(licenseValid == true)
    savingUpdate = true

    var uploadPublishers: [AnyPublisher<(ImageUploadKind, URL), Error>] = []

    if let profileImageData = profileImageData {
      let uploadProfileImagePublisher = StorageService.shared
        .uploadPictureData(
          profileImageData,
          path: .profilePictures(fileName: courier.id)
        )
        .map { (ImageUploadKind.profile, $0) }
        .eraseToAnyPublisher()
      uploadPublishers.append(uploadProfileImagePublisher)
    }
    
    if let licenseImageData = license.imageData {
      let uploadLicenseImagePublisher = StorageService.shared
        .uploadPictureData(
          licenseImageData,
          path: .licensePictures(fileName: courier.id)
        )
        .map { (ImageUploadKind.license, $0) }
        .eraseToAnyPublisher()
      uploadPublishers.append(uploadLicenseImagePublisher)
    }
    
    guard !uploadPublishers.isEmpty else {
      updateCourier()
      return
    }
    
    Publishers.MergeMany(uploadPublishers)
      .collect()
      .subscribe(on: queue)
      .receive(on: DispatchQueue.main)
      .sink { completion in
        if case .failure(let error) = completion {
          self.errorMessage = error.localizedDescription
        }
        self.savingUpdate = false
      } receiveValue: { [weak self] uploadUrls in
        uploadUrls.forEach { kindUrl in
          let (kind, url) = kindUrl
          switch kind {
          case .profile: self?.courier.profilePictureUrl = url
          case .license: self?.courier.license.imageUrl = url
          }
        }
        self?.updateCourier()
      }
      .store(in: &subscriptions)
  }
  
  private func updateCourier() {
    courier.name = fullName
    courier.bikeBrand = bikeBrand
    courier.bikePlate = bikePlate
    courier.license.licenseNo = license.licenseNo
    
    courierRepo.updateCourier(courier)
      .subscribe(on: queue)
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { [weak self] completion in
        if case .failure(let error) = completion {
          self?.errorMessage = error.localizedDescription
        }
        self?.savingUpdate = false
      }, receiveValue: { [weak self] courier in
        self?.mainViewModel.setCourier(courier)
      })
      .store(in: &subscriptions)
  }
  
  private var madeChanges: Bool {
    (mainViewModel.courier.name != fullName)
    || (mainViewModel.courier.bikeBrand != bikeBrand)
    || (mainViewModel.courier.bikePlate != bikePlate)
    || (mainViewModel.courier.license.licenseNo != license.licenseNo)
    || (profileImageData != nil)
    || (license.imageData != nil)
  }
  
  func validateNameIfFocusIsLost(_ focus: Bool) {
    guard focus == false else { return }
    nameValid = !fullName.isEmpty
  }
  
  func validateBikeBrandIfFocusIsLost(_ focus: Bool) {
    guard focus == false else { return }
    bikeBrandValid = !bikeBrand.isEmpty
  }
  
  func validateBikePlateIfFocusIsLost(focus: Bool) {
    guard focus == false else { return }
    bikePlateValid = !bikePlate.isEmpty
  }
  
  func validateLicenseIfFocusIsLost(focus: Bool) {
    guard focus == false else { return }
    licenseValid = !license.licenseNo.isEmpty
  }
}
