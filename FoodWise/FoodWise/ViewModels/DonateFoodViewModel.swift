//
//  DonateFoodViewModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 13/03/22.
//

import Foundation
import Combine

class DonateFoodViewModel: ObservableObject {
  @Published var showingImagePicker: Bool = false {
    didSet {
      if !showingImagePicker {
        isImageDataValid = imageData != nil
      }
    }
  }
  @Published var showingLocationPicker: Bool = false
  @Published var showingCameraLibraryDialog: Bool = false
  @Published var showingSubmitSnackbar: Bool = false
  @Published var showingErrorSnackbar: Bool = false
  @Published var imageData: Data? = nil
  @Published var selectedKind: SharedFoodKind? = nil
  @Published var foodName: String = ""
  @Published var note: String = ""
  @Published private var newDonation: DonationModel? = nil
  
  @Published private(set) var isSubmittingDonation = false
  
  var newDonationPublisher: AnyPublisher<DonationModel, Never> {
    $newDonation.compactMap({ $0 }).eraseToAnyPublisher()
  }
  var address: Address? = nil {
    willSet { isLocationValid = newValue != nil }
  }
  
  var buttonDisabled: Bool {
    guard let isImageDataValid = isImageDataValid,
          let isNameValid = isNameValid,
          let isLocationValid = isLocationValid else {
            return true
          }
    return !(isImageDataValid && isNameValid && isLocationValid && isKindValid)
  }
  private(set) var isImageDataValid: Bool?
  @Published private(set) var isNameValid: Bool?
  private(set) var isLocationValid: Bool?
  
  private var isKindValid: Bool { selectedKind != nil }
  
  private let repository: DonationRepository
  private var subscriptions: Set<AnyCancellable> = []
  
  init(repository: DonationRepository) {
    self.repository = repository
    $foodName
      .dropFirst()
      .debounce(for: .milliseconds(800), scheduler: RunLoop.main)
      .map { !$0.isEmpty }
      .assign(to: \.isNameValid, on: self)
      .store(in: &subscriptions)
  }
  
  
  func submitDonation(donor: Customer) {
    validateNameField()
    guard !buttonDisabled else { return }
    showingSubmitSnackbar = true
    isSubmittingDonation = true
    let uploadPictureDataPublisher = StorageService.shared.uploadPictureData(
      imageData!,
      path: .donationPictures(fileName: "Donation_\(donor.id)_\(Date.now)"))
    
    uploadPictureDataPublisher
      .flatMap { [weak self] pictureUrl -> AnyPublisher<Donation, Error> in
        guard let self = self else {
          return Fail(error: NSError()).eraseToAnyPublisher()
        }
        return self.repository.createDonation(pictureUrl: pictureUrl, kind: self.selectedKind!, foodName: self.foodName, pickupLocation: self.address!, notes: self.note, donorId: donor.id)
      }
      .sink { [weak self] completion in
        if case .failure(let error) = completion {
          print("Failed to create donation with error: \(error)")
          self?.showingErrorSnackbar = true
        }
        self?.isSubmittingDonation = false
      } receiveValue: { [weak self] donation in
        self?.newDonation = DonationModel(donation: donation,
                                          donorUser: donor)
      }
      .store(in: &subscriptions)
  }
  
  func validateNameField() {
    
    self.isNameValid = !foodName.isEmpty
  }
  
  
}
