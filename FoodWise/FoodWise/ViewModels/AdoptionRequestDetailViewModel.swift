//
//  AdoptionRequestDetailViewModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 16/03/22.
//

import Foundation
import Combine

class AdoptionRequestDetailViewModel: ObservableObject {
  @Published var showedMessageRequest: AdoptionRequest? = nil
  @Published var showingAcceptAlert: Bool = false
  @Published var showingAcceptingSnackbar: Bool = false
  @Published var showingErrorSnackbar: Bool = false
  
  @Published private(set) var donation: Donation
  private let repository: DonationRepository
  private let customerRepository: CustomerRepository
  private var subscriptions: Set<AnyCancellable> = []
  private(set) var toBeAcceptedRequest: AdoptionRequest? = nil
  
  lazy var cellDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd MMMM yyyy 'at' h:mm a"
    return formatter
  }()
  
  private var donationSubject: PassthroughSubject<Donation, Never> = .init()
  
  var donationPublisher: AnyPublisher<Donation, Never> {
    donationSubject.eraseToAnyPublisher()
  }
  
  init(donation: Donation, repository: DonationRepository, customerRepository: CustomerRepository = CustomerRepository()) {
    self.donation = donation
    self.repository = repository
    self.customerRepository = customerRepository
  }
  
  func showAcceptAlert(withRequest request: AdoptionRequest) {
    toBeAcceptedRequest = request
    showingAcceptAlert = true
  }
  
  func acceptRequest(currentUser: Customer) {
    guard let request = toBeAcceptedRequest else { return }
    showingAcceptingSnackbar = true
    let mailPublisher = SMTPService.sendAcceptedAdoptionRequest(
      data: .init(userEmail: request.requesterCustomer.email,
                  userName: request.requesterCustomer.fullName,
                  requestSentDate: cellDateFormatter.string(from: request.date.dateValue()),
                  foodName: donation.foodName,
                  donorName: currentUser.fullName))
    let acceptRequestPublisher = repository.acceptAdoptionRequest(request, for: donation)
    mailPublisher
      .flatMap { _ in acceptRequestPublisher }
      .sink { [weak self] completion in
        if case .failure(let error) = completion {
          print("completion failed with error: \(error)")
          self?.showingErrorSnackbar = true
        }
      } receiveValue: { [weak self] _ in
        guard let self = self else { return }
        self.donationSubject.send(self.donation)
        self.donationSubject.send(completion: .finished)
      }
      .store(in: &subscriptions)
  }
}
