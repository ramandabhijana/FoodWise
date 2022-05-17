//
//  DonationDetailsViewModel.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 15/03/22.
//

import Foundation
import Combine

class DonationDetailsViewModel: ObservableObject {
  @Published var showingMessageSheet: Bool = false {
    willSet { if !newValue { messageText = "" } }
  }
  @Published var showingMapView: Bool = false
  @Published var showingChatView: Bool = false
  @Published var showingSendingSnackbar: Bool = false
  @Published var showingSuccessAlert: Bool = false
  @Published var showingErrorSnackbar: Bool = false
  @Published var showingPhotoViewer: Bool = false
  @Published var messageText: String = ""
  
  private(set) var donationModel: DonationModel
  private let repository: DonationRepository
  private(set) var currentCustomer: Customer
  private var subscriptions: Set<AnyCancellable> = []
  
  var isDonatedByCurrentCustomer: Bool {
    donationModel.donation.donorId == currentCustomer.id
  }
  var donation: Donation { donationModel.donation }
  var sharer: Customer { donationModel.donorUser }
  var buttonDisabled: Bool {
    donation.status != DonationStatus.available.rawValue || isDonatedByCurrentCustomer
  }
  var sendRequestButtonText: String {
    guard !isDonatedByCurrentCustomer else { return "You donated this food" }
    return donation.status == DonationStatus.available.rawValue ? "Send Request" : "Not available"
  }
  
  init(donationModel: DonationModel,
       currentCustomer: Customer,
       repository: DonationRepository) {
    self.donationModel = donationModel
    self.currentCustomer = currentCustomer
    self.repository = repository
  }
  
  func sendRequest() {
    let request = AdoptionRequest(messageForDonor: messageText,
                                  requesterCustomer: currentCustomer)
    showingMessageSheet = false
    showingSendingSnackbar = true
    repository.addAdoptionRequest(request, toDonationWithId: donationModel.id)
      .sink { [weak self] completion in
        if case .failure(let error) = completion {
          print("addAdoptionRequest complete with error: \(error)")
          self?.showingErrorSnackbar = true
        }
      } receiveValue: { [weak self] _ in
        self?.showingSuccessAlert = true
      }
      .store(in: &subscriptions)
  }
  
}

/*
 let regionDistance: CLLocationDistance = 0.1
 let regionSpan = MKCoordinateRegion(center: loc.location.coordinate,
                                     latitudinalMeters: regionDistance,
                                     longitudinalMeters: regionDistance)
 let options = [
     MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
     MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
 ]
 let placemark = MKPlacemark(coordinate: loc.location.coordinate, addressDictionary: nil)
 let mapItem = MKMapItem(placemark: placemark)
 mapItem.openInMaps(launchOptions: options)
 */
