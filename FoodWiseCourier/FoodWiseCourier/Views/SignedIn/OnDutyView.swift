//
//  OnDutyView.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 10/04/22.
//

import SwiftUI
import MapKit
import SDWebImageSwiftUI
import Contacts

struct OnDutyView: View {
  @EnvironmentObject var mainViewModel: MainViewModel
  @ObservedObject private var homeViewModel: HomeViewModel
  @ObservedObject var viewModel: OnDutyModel
  
  private let currentCoordinateItem: MKMapItem
  private let pickupCoordinateItem: MKMapItem
  private let dropoffCoordinateItem: MKMapItem
  private static var verificationViewModel: OrderVerificationViewModel!
  
  init(homeViewModel: HomeViewModel, viewModel: OnDutyModel) {
    self.homeViewModel = homeViewModel
    self.viewModel = viewModel
    currentCoordinateItem = MKMapItem(placemark: MKPlacemark(coordinate: homeViewModel.currentCoordinate!))
    pickupCoordinateItem = MKMapItem(placemark: MKPlacemark(coordinate: viewModel.deliveryTask.pickupAddress.clLocation.coordinate))
    dropoffCoordinateItem = MKMapItem(placemark: MKPlacemark(coordinate: viewModel.deliveryTask.dropOffAddress.clLocation.coordinate))
  }
  
  var body: some View {
    TabView {
      makeMainView()
      makeDeliveryDetailsView()
    }
    .tabViewStyle(.page)
    .indexViewStyle(.page(backgroundDisplayMode: .always))
    .navigationBarTitleDisplayMode(.inline)
    .ignoresSafeArea()
    .onAppear {
      setNavigationBarColor(withStandardColor: .backgroundColor, andScrollEdgeColor: .backgroundColor)
    }
    .fullScreenCover(isPresented: $viewModel.showingVerificationView) {
      OrderVerificationView(viewModel: Self.verificationViewModel)
//      QRScanViewController.View<OrderVerificationViewModel>()
    }
    .snackBar(
      isShowing: $viewModel.showingError,
      text: Text("An error occurred"),
      isError: true
    )
    .onReceive(viewModel.dutyFinishedPublisher) { _ in
      homeViewModel.isOnDuty = false
      homeViewModel.onDutyTask = nil
      homeViewModel.removeTrackingSession()
    }
  }
  
  private func makeMainView() -> some View {
    VStack(spacing: 0) {
      Group {
        if viewModel.isDeliveringItems {
          RouteMapView(
            route: MapRoute(
            origin: pickupCoordinateItem,
            destination: dropoffCoordinateItem),
            mapVisibleRectToInitialPublisher: viewModel.mapVisibleRectToInitialPublisher
          )
        } else {
          RouteMapView(
            route: MapRoute(
            origin: currentCoordinateItem,
            destination: pickupCoordinateItem),
            mapVisibleRectToInitialPublisher: viewModel.mapVisibleRectToInitialPublisher
          )
        }
      }
        .frame(height: UIScreen.main.bounds.height * 0.45)
        .overlay(alignment: .bottomTrailing) {
          Button(action: viewModel.centerVisibleMapRect) {
            Image("map_center")
              .resizable()
              .frame(width: 20, height: 20)
              .padding(5)
              .background(
                RoundedRectangle(cornerRadius: 8)
                  .strokeBorder(Color.accentColor, lineWidth: 2)
                  .background(Color.white)
                  .cornerRadius(8)
              )
          }
          .padding()
          .padding(.bottom)
        }
      
      VStack(alignment: .leading, spacing: 22) {
        VStack(alignment: .leading, spacing: 10) {
          Text("User at destination")
            .bold()
          HStack {
            WebImage(url: .init(string: viewModel.userAtLocation?.profilePicUrl ?? ""))
              .resizable()
              .placeholder {
                Image(systemName: "person.circle.fill")
                  .resizable()
                  .frame(width: 30, height: 30)
                  .foregroundColor(.gray)
              }
              .frame(width: 30, height: 30)
              .clipShape(Circle())
            Text(viewModel.userAtLocation?.name ?? "Customer name")
              .font(.subheadline)
            Spacer()
            Button(action: { viewModel.showingChatRoomWithUserAtDestinationView = true }) {
              Text("Chat")
                .padding(5)
                .padding(.horizontal)
                .background(
                  RoundedRectangle(cornerRadius: 5)
                    .strokeBorder(lineWidth: 2)
                )
            }
            .disabled(viewModel.userAtLocation?.type == nil)
            .background(
              NavigationLink(
                isActive: $viewModel.showingChatRoomWithUserAtDestinationView,
                destination: {
                  LazyView(ChatRoomView(
                    userId: mainViewModel.courier.id,
                    otherUserType: viewModel.userAtLocation?.type ?? "",
                    otherUserProfilePictureUrl: URL(string: viewModel.userAtLocation?.profilePicUrl ?? ""),
                    otherUserName: viewModel.userAtLocation?.name ?? "",
                    otherUserId: viewModel.userAtLocation?.id ?? ""))
                },
                label: EmptyView.init)
            )
          }
          .redacted(reason: viewModel.userAtLocation == nil ? .placeholder : [])
        }
        Divider()
        VStack(alignment: .leading, spacing: 10) {
          Text(viewModel.currentDestination.title).bold()
          VStack(alignment: .leading) {
            Text(viewModel.currentDestination.address.geocodedLocation)
              .font(.subheadline)
            Text("Details: \(viewModel.currentDestination.address.details)")
              .font(.footnote)
          }
          .padding(.bottom)
          Button(action: getDirection) {
            RoundedRectangle(cornerRadius: 8)
              .frame(height: 44)
              .overlay {
                Text("Get Direction").foregroundColor(.white)
              }
          }
        }
      }
      .padding()
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(Rectangle().fill(Color.white))
      Spacer()
    }
    .navigationTitle(viewModel.mainViewTitle)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        if viewModel.loading {
          ProgressView()
            .progressViewStyle(.circular)
        } else {
          if viewModel.isDeliveringItems {
            Button("Scan QR") {
              Self.verificationViewModel = .init(deliveryTask: viewModel.deliveryTask)
              
              viewModel.showingVerificationView = true
            }
          } else {
            Button("Done") {
              viewModel.showingFinishedPickingUpItemsAlert = true
            }
          }
        }
      }
    }
    .alert("Finish pick up items and continue to the next destination?",
           isPresented: $viewModel.showingFinishedPickingUpItemsAlert) {
      Button("Cancel", role: .cancel) { }
      Button("Yes") {
        guard let session = homeViewModel.session else { return }
        viewModel.finishPickingUpItems(
          courierId: session.courierId,
          repository: homeViewModel.sessionRepository) { task in
            homeViewModel.onDutyTask = task
          }
      }
    }
          
  }
  
  private func makeDeliveryDetailsView() -> some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 22) {
        // Delivery Status
        VStack(alignment: .leading) {
          Text("Delivery Status")
            .bold()
          VStack(alignment: .leading, spacing: 0) {
            makeDeliveryStatusItem(status: viewModel.deliveryTask.status![safe: 0]!)
            makeStatusSeparatorLine()
            makeDeliveryStatusItem(status: viewModel.deliveryTask.status![safe: 1]
                                   ?? .init(status: .itemsPickedUp))
            makeStatusSeparatorLine()
            makeDeliveryStatusItem(status: viewModel.deliveryTask.status![safe: 2]
                                   ?? .init(status: .received))
          }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
          RoundedRectangle(cornerRadius: 8)
            .fill(Color.white)
            .shadow(radius: 2)
        )
        
        // Requester
        VStack(alignment: .leading) {
          Text("Requester")
            .bold()
          HStack {
            WebImage(url: .init(string: viewModel.deliveryTask.requesterProfilePicUrl))
              .resizable()
              .placeholder {
                Image(systemName: "person.circle.fill")
                  .resizable()
                  .frame(width: 30, height: 30)
                  .foregroundColor(.gray)
              }
              .frame(width: 30, height: 30)
              .clipShape(Circle())
            Text(viewModel.deliveryTask.requesterName)
              .font(.subheadline)
            Spacer()
            Button(action: { viewModel.showingChatRoomWithRequesterView = true }) {
              Text("Chat")
                .font(.subheadline)
                .padding(5)
                .padding(.horizontal)
                .background(
                  RoundedRectangle(cornerRadius: 5)
                    .strokeBorder(lineWidth: 2)
                )
            }
            .background(
              NavigationLink(
                isActive: $viewModel.showingChatRoomWithRequesterView,
                destination: {
                  LazyView(ChatRoomView(
                    userId: mainViewModel.courier.id,
                    otherUserType: viewModel.deliveryTask.requesterType,
                    otherUserProfilePictureUrl: URL(string: viewModel.deliveryTask.requesterProfilePicUrl),
                    otherUserName: viewModel.deliveryTask.requesterName,
                    otherUserId: viewModel.deliveryTask.requesterId))
                },
                label: EmptyView.init)
            )
          }
          Text(viewModel.deliveryTask.requestedDateFormatted)
            .font(.caption.bold())
            .foregroundColor(.secondary)
            .padding(.top, 4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
          RoundedRectangle(cornerRadius: 8)
            .fill(Color.white)
            .shadow(radius: 2)
        )
        
        // Route
        VStack(alignment: .leading) {
          Text("Route")
            .bold()
            .padding(.bottom, 4)
          RouteView(pickupAddress: viewModel.deliveryTask.pickupAddress.geocodedLocation, pickupDetails: viewModel.deliveryTask.pickupAddress.details, destinationAddress: viewModel.deliveryTask.dropOffAddress.geocodedLocation, destinationDetails: viewModel.deliveryTask.dropOffAddress.details)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
          RoundedRectangle(cornerRadius: 8)
            .fill(Color.white)
            .shadow(radius: 2)
        )
        
        // Items
        VStack(alignment: .leading) {
          HStack {
            Text("Items")
              .bold()
              .padding(.bottom, 4)
            Spacer()
            // Only show if delivering items
            if viewModel.isDeliveringItems {
              Button(action: {
                Self.verificationViewModel = .init(deliveryTask: viewModel.deliveryTask)
                viewModel.showingVerificationView = true
              }) {
                Text("Scan QR")
                  .font(.subheadline.bold())
                  .foregroundColor(.white)
                  .padding(5)
                  .padding(.horizontal)
                  .background(RoundedRectangle(cornerRadius: 5))
              }
              
            }
          }
          // Order items
          VStack(spacing: 16) {
            ForEach(viewModel.deliveryItems, content: makeDeliveryItemCell)
          }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
          RoundedRectangle(cornerRadius: 8)
            .fill(Color.white)
            .shadow(radius: 2)
        )
      }
      .padding()
    }
    .navigationTitle("Delivery Details")
    .background(Color.backgroundColor)
  }
  
  private func makeDeliveryStatusItem(status: DeliveryStatus) -> some View {
    HStack {
      if status.date != nil {
        ZStack {
          Circle()
            .fill(Color.primaryColor)
            .frame(width: 30, height: 30)
            .overlay {
              Text("\(Image(systemName: "checkmark"))")
                .font(.footnote)
                .fontWeight(.bold)
                .foregroundColor(.black)
            }
          Circle()
            .strokeBorder(Color(uiColor: .darkGray), lineWidth: 1.5)
            .frame(width: 30, height: 30)
        }
        VStack(alignment: .leading) {
          Text(status.status)
            .lineLimit(1)
            .font(.subheadline)
          Text(status.formattedDate)
            .lineLimit(1)
            .font(.caption)
        }
      } else {
        ZStack {
          Circle()
            .strokeBorder(Color.secondary, lineWidth: 1.5)
            .frame(width: 30, height: 30)
        }
        VStack(alignment: .leading) {
          Text(status.status)
            .lineLimit(1)
            .font(.subheadline)
          Text("-")
            .lineLimit(1)
            .font(.caption)
        }
      }
    }
  }
  
  private func makeStatusSeparatorLine() -> some View {
    VLine()
      .stroke(style: StrokeStyle(
        lineWidth: 1.5,
        lineCap: CGLineCap.round,
        dash: [6])
      )
      .frame(width: 30, height: 22, alignment: .center)
      .foregroundColor(viewModel.deliveryTask.status![safe: 1] == nil ? .secondary : .init(uiColor: .darkGray))
  }
  
  private func makeDeliveryItemCell(deliveryItem: OnDutyModel.DeliveryItem) -> some View {
    VStack(spacing: 8) {
      HStack(spacing: 10) {
        WebImage(url: deliveryItem.imageUrl)
          .resizable()
          .frame(width: 35, height: 35)
          .cornerRadius(8)
        Text(deliveryItem.name)
          .font(Font.subheadline)
          .frame(maxWidth: .infinity, alignment: .leading)
        Spacer()
        Text("×\(deliveryItem.quantity)")
          .font(Font.footnote)
          .bold()
        Spacer()
        Text(NumberFormatter.rpCurrencyFormatter.string(from: .init(value: deliveryItem.price)) ?? "-")
          .bold()
          .font(.footnote)
      }
      Divider()
    }
  }
  
  private func getDirection() {
    guard let deliveryStatus = viewModel.deliveryTask.status?.last,
          let statusValue = deliveryStatus.statusValue else { return }
    var addressDict: [String: String]
    var coordinate: CLLocationCoordinate2D
    if statusValue == .requestAccepted {
      addressDict = [CNPostalAddressStreetKey: viewModel.deliveryTask.pickupAddress.geocodedLocation]
      coordinate = viewModel.deliveryTask.pickupAddress.clLocation.coordinate
    } else {
      addressDict = [CNPostalAddressStreetKey: viewModel.deliveryTask.dropOffAddress.geocodedLocation]
      coordinate = viewModel.deliveryTask.dropOffAddress.clLocation.coordinate
    }
    let placemark = MKPlacemark(coordinate: coordinate,
                                addressDictionary: addressDict)
    let mapItem = MKMapItem(placemark: placemark)
    let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
    mapItem.openInMaps(launchOptions: launchOptions)
  }
}

//struct OnDutyView_Previews: PreviewProvider {
//  static var previews: some View {
//    OnDutyView()
//  }
//}

private extension OnDutyView {
  struct RouteView: View {
    @State private var pickupLocationVLineSize: CGSize = .init()
    @State private var destinationLocationVLineSize: CGSize = .init()
    let pickupAddress: String
    let pickupDetails: String
    let destinationAddress: String
    let destinationDetails: String
    
    var body: some View {
      VStack(alignment: .leading, spacing: 0) {
        VStack(alignment: .leading, spacing: 0) {
          Text("Pickup Location")
            .font(.footnote)
            .padding(.leading, 30)
          HStack(alignment: .top, spacing: 10) {
            VStack {
              Image(systemName: "circle.circle")
                .font(.subheadline.bold())
              VLine()
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
            }
            .frame(width: 20, height: pickupLocationVLineSize.height)
            VStack(alignment: .leading) {
              Text(pickupAddress)
                .font(.subheadline.bold())
              Text("Details: \(pickupDetails.isEmpty ? "-" : pickupDetails)")
                .font(.caption)
            }
            .readSize { pickupLocationVLineSize = $0 }
          }
        }
        
        VLine()
          .stroke(style: StrokeStyle(
            lineWidth: 1,
            dash: [5])
          )
          .frame(width: 20, height: 20)
        
        VStack(alignment: .leading, spacing: 0) {
          HStack(spacing: 10) {
            VLine()
              .stroke(style: StrokeStyle(
                lineWidth: 1,
                dash: [5])
              )
              .frame(
                width: 20,
                height: destinationLocationVLineSize.height
              )
            Text("Drop-off Location")
              .font(.footnote)
              .readSize { destinationLocationVLineSize = $0 }
          }
          HStack(alignment: .top, spacing: 10) {
            Image(systemName: "mappin.and.ellipse")
              .font(.subheadline.bold())
              .frame(width: 20)
            VStack(alignment: .leading) {
              Text(destinationAddress)
                .font(.subheadline.bold())
              Text("Details: \(destinationDetails.isEmpty ? "-" : destinationDetails)")
                .font(.caption)
            }
          }
        }
      }
    }
  }
}
