//
//  SharingArchiveView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 04/05/22.
//

import SwiftUI
import SDWebImageSwiftUI
import Contacts
import MapKit

struct SharingArchiveView: View {
  @StateObject private var viewModel: SharingArchiveViewModel
  static fileprivate var selectLocationViewModel: SelectLocationViewModel!
  static fileprivate var verificationViewModel: ReceiptVerificationViewModel!
  static private var requestDeliveryViewModel: RequestDeliveryViewModel!
  
  init(viewModel: SharingArchiveViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var body: some View {
    VStack {
      Group {
        switch viewModel.displayedList {
        case .shared: sharedSearchField
        case .received: receivedSearchField
        }
      }
      .padding([.horizontal, .top])
      
      List {
        Group {
          switch viewModel.displayedList {
          case .shared:
            ForEach(
              viewModel.filteredSharedList,
              id: \.self,
              content: makeSharedCell
            )
            .padding(.vertical, 4)
          case .received:
            ForEach(
              viewModel.filteredReceivedList,
              id: \.self,
              content: makeReceivedCell
            )
            .padding(.vertical, 4)
          }
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
      }
      .listStyle(.plain)
      .refreshable {
        viewModel.refreshList()
      }
      .overlay {
        emptyList
      }
    }
    .background(Color.backgroundColor)
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      setNavigationBarColor(withStandardColor: .primaryColor, andScrollEdgeColor: .primaryColor)
      NotificationCenter.default.post(name: .tabBarHiddenNotification, object: nil)
    }
    .toolbar {
      ToolbarItem(placement: .principal) {
        Picker("Shared | Received", selection: $viewModel.displayedList) {
          Text("Shared").tag(SharingArchiveViewModel.DisplayedList.shared)
          Text("Received").tag(SharingArchiveViewModel.DisplayedList.received)
        }
        .pickerStyle(.segmented)
        .frame(width: UIScreen.main.bounds.width * 0.5)
      }
    }
    .fullScreenCover(isPresented: $viewModel.showingDropoffLocationPickerForReceivedDonation.0) {
      if
        let coordinate = Self.selectLocationViewModel.coordinate,
        let selectedReceivedDonation = viewModel.showingDropoffLocationPickerForReceivedDonation.1
      {
        Self.requestDeliveryViewModel = RequestDeliveryViewModel(
          pickupGeoCooordinate: selectedReceivedDonation.pickupLocation.clLocation.coordinate,
          destinationGeoCoordinate: coordinate,
          pickupAddress: selectedReceivedDonation.pickupLocation.geocodedLocation,
          pickupDetails: selectedReceivedDonation.pickupLocation.details,
          destinationAddress: Self.selectLocationViewModel.geocodedLocation,
          destinationDetails: Self.selectLocationViewModel.addressDetails,
          donation: selectedReceivedDonation)
        
        viewModel.listenDeliveryTaskAssignedPublisher(
          Self.requestDeliveryViewModel.deliveryTaskAssignedPublisher,
          forReceivedDonation: selectedReceivedDonation)
        
        viewModel.showingDropoffLocationPickerForReceivedDonation.0 = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
          viewModel.showingRequestDeliveryView = true
        }
      }
    } content: {
      LazyView(SelectLocationView(viewModel: Self.selectLocationViewModel))
    }
    .fullScreenCover(isPresented: $viewModel.showingRequestDeliveryView, content: {
      RequestDeliveryView(viewModel: Self.requestDeliveryViewModel)
    })
    .fullScreenCover(isPresented: $viewModel.showingVerificationView, content: {
      ReceiptVerificationView(viewModel: Self.verificationViewModel)
    })
    .snackBar(
      isShowing: $viewModel.showingError,
      text: Text("Unknown error occurred"),
      isError: true
    )
  }
  
  private func makeReceivedCell(_ model: DonationModel) -> some View {
    ReceivedCell(sharingArchiveViewModel: viewModel, model: model)
  }
  
  private func makeSharedCell(_ model: SharingArchiveViewModel.SharedFoodModel) -> some View {
    SharedCell(sharingArchiveViewModel: viewModel, model: model)
  }
  
  private var sharedSearchField: some View {
    TextField("Search by food's or recipient's name", text: $viewModel.sharedListSearchText)
      .disableAutocorrection(true)
      .padding(8)
      .background(Color.secondary.opacity(0.2))
      .cornerRadius(8)
      .overlay(alignment: .trailing) {
        if !viewModel.sharedListSearchText.isEmpty {
          Button(action: viewModel.clearSharedListSearchText) {
            Image(systemName: "xmark.circle.fill")
              .font(.caption)
              .padding(.trailing, 8)
              .foregroundColor(.secondary)
          }
        }
      }
  }
  
  private var receivedSearchField: some View {
    TextField("Search by food's or sharer's name", text: $viewModel.receivedListSearchText)
      .disableAutocorrection(true)
      .padding(8)
      .background(Color.secondary.opacity(0.2))
      .cornerRadius(8)
      .overlay(alignment: .trailing) {
        if !viewModel.receivedListSearchText.isEmpty {
          Button(action: viewModel.clearReceivedListSearchText) {
            Image(systemName: "xmark.circle.fill")
              .font(.caption)
              .padding(.trailing, 8)
              .foregroundColor(.secondary)
          }
        }
      }
  }
}

private struct SharedCell: View {
  @ObservedObject var sharingArchiveViewModel: SharingArchiveViewModel
  
  var model: SharingArchiveViewModel.SharedFoodModel
  
  var body: some View {
    VStack(alignment: .leading, spacing: 15) {
      Text(SharingArchiveViewModel.sharedCellDateFormatter.string(from: model.donation.date.dateValue()))
        .font(.caption)
        .foregroundColor(.secondary)
      
      HStack {
        WebImage(url: model.donation.pictureUrl)
          .resizable()
          .frame(width: 60, height: 60)
          .cornerRadius(8)
        VStack(alignment: .leading, spacing: 5) {
          Text(model.donation.foodName)
            .lineLimit(2)
            .font(.callout)
          Text(model.donation.kind)
            .font(.caption2)
        }
        Spacer(minLength: 15)
        if model.donation.status == DonationStatus.booked.rawValue,
           model.donation.deliveryTaskId == nil {
          Button(action: {
            SharingArchiveView.verificationViewModel = ReceiptVerificationViewModel(donatedFood: model.donation)
            sharingArchiveViewModel.donatedFoodToBeVerified = model.donation
            sharingArchiveViewModel.showingVerificationView = true
          }) {
            Image(systemName: "qrcode.viewfinder")
              .font(.title)
              
          }
          .foregroundColor(.accentColor)
        }
      }
      
      VStack(alignment: .leading, spacing: 7) {
        HStack {
          Image(systemName: "person.fill")
            .font(.caption)
            .frame(width: 15)
          Text({ () -> String in
            guard let recipient = model.recipientCustomer else { return "-" }
            return "\(recipient.fullName) • \(SharingArchiveViewModel.cellConfirmedDateDateFormatter.string(for: model.donation.adoptionRequests.first?.date.dateValue()) ?? "-")"
          }())
          .font(.caption.bold())
        }
      }
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(Color.white)
        .shadow(radius: 2)
    )
    .redacted(reason: sharingArchiveViewModel.loadingSharedList ? .placeholder : [])
  }
}

private struct ReceivedCell: View {
  @State private var showingReceipt = false
  @State private var showingTrackingView = false
  @ObservedObject var sharingArchiveViewModel: SharingArchiveViewModel
  
  var model: DonationModel
  
  var body: some View {
    VStack(alignment: .leading, spacing: 15) {
      Text(SharingArchiveViewModel.receivedCellDateFormatter.string(from: model.donation.adoptionRequests.first?.date.dateValue() ?? .now))
        .font(.caption)
        .foregroundColor(.secondary)
        .background {
          if let deliveryTaskId = model.donation.deliveryTaskId {
            NavigationLink(
              isActive: $showingTrackingView,
              destination: {
                LazyView(DeliveryTrackingView(viewModel: DeliveryTrackingViewModel(deliveryTaskId: deliveryTaskId)))
              },
              label: EmptyView.init
            )
            .frame(width: 0).opacity(0.0)
          }
        }
      
      
      
      HStack {
        WebImage(url: model.donation.pictureUrl)
          .resizable()
          .frame(width: 60, height: 60)
          .cornerRadius(8)
        VStack(alignment: .leading, spacing: 5) {
          Text(model.donation.foodName)
            .lineLimit(2)
            .font(.callout)
          Text(model.donation.kind)
            .font(.caption2)
        }
        Spacer(minLength: 15)
        Menu {
          Button("View Receipt") {
            showingReceipt = true
          }
          
          // Change to track if delivery is used
          if model.donation.status != DonationStatus.received.rawValue {
            if let deliveryTaskId = model.donation.deliveryTaskId {
              Button("Track Delivery") {
                showingTrackingView = true
              }
              
              /*
              NavigationLink {
                LazyView(DeliveryTrackingView(viewModel: DeliveryTrackingViewModel(deliveryTaskId: deliveryTaskId)))
              } label: {
                Text("Track Delivery")
              }
               */
               
//              NavigationLink(
//                isActive: $showingTrackingView,
//                destination: {
//                  LazyView(DeliveryTrackingView(viewModel: DeliveryTrackingViewModel(deliveryTaskId: deliveryTaskId)))
//                },
//                label: EmptyView.init)
              /*
              Button("Track Delivery") {
                showingTrackingView = true
              }
              .overlay {
                NavigationLink(
                  isActive: $showingTrackingView,
                  destination: {
                    LazyView(DeliveryTrackingView(viewModel: DeliveryTrackingViewModel(deliveryTaskId: deliveryTaskId)))
                  },
                  label: EmptyView.init)
              }
              */
            } else {
              Button("Use Delivery") {
                SharingArchiveView.selectLocationViewModel = SelectLocationViewModel()
                SharingArchiveView.selectLocationViewModel.fetchUserLocation()
                SharingArchiveView.selectLocationViewModel = SharingArchiveView.selectLocationViewModel
                sharingArchiveViewModel.showingDropoffLocationPickerForReceivedDonation = (true, model.donation)
              }
            }
          
            // Hide if donation status == finished
            Button("Pick-up Location") {
              let pickupLocation = model.donation.pickupLocation
              let addressDict = [CNPostalAddressStreetKey: pickupLocation.geocodedLocation]
              let placemark = MKPlacemark(
                coordinate: pickupLocation.clLocation.coordinate,
                addressDictionary: addressDict
              )
              MKMapItem(placemark: placemark).openInMaps()
            }
          }
        } label: {
          Image(systemName: "ellipsis")
            .foregroundColor(.accentColor)
            .font(.body.bold())
            .rotationEffect(.degrees(-90))
            .padding(5)
            .padding(.vertical, 10)
            .background(Color.accentColor.opacity(0.15))
            .clipShape(Circle())
        }
      }
      
      VStack(alignment: .leading, spacing: 7) {
        HStack {
          Image(systemName: "person.fill")
            .font(.caption)
            .frame(width: 15)
          Text("\(model.donorUser.fullName) • \(SharingArchiveViewModel.cellConfirmedDateDateFormatter.string(from: model.donation.date.dateValue()))")
            .font(.caption.bold())
        }
        HStack {
          Image(systemName: "mappin.and.ellipse")
            .font(.caption)
            .frame(width: 15)
          Text(model.donation.pickupLocation.geocodedLocation)
            .font(.caption.bold())
        }
      }
      
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(Color.white)
        .shadow(radius: 2)
    )
    .redacted(reason: sharingArchiveViewModel.loadingReceivedList ? .placeholder : [])
    .fullScreenCover(isPresented: $showingReceipt) {
      FoodSharingReceiptView(viewModel: FoodSharingReceiptModel(
        donation: model.donation,
        sharerName: model.donorUser.fullName))
    }
  }
}

private extension SharingArchiveView {
  @ViewBuilder
  var emptyList: some View {
    switch viewModel.displayedList {
    case .received:
      if viewModel.filteredReceivedList.isEmpty { emptyListLabel }
    case .shared:
      if viewModel.filteredSharedList.isEmpty { emptyListLabel }
    }
  }
  
  var emptyListLabel: some View {
    VStack {
      Image("empty_list")
        .resizable()
        .scaledToFit()
        .frame(width: 100, height: 100)
      Text("No results").font(.subheadline)
    }
    .frame(width: UIScreen.main.bounds.width,
           height: UIScreen.main.bounds.height)
  }
}
