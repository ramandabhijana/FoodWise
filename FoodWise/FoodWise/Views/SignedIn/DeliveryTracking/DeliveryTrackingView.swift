//
//  DeliveryTrackingView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 15/04/22.
//

import SwiftUI
import MapKit
import SDWebImageSwiftUI

struct DeliveryTrackingView: View {
  @EnvironmentObject private var rootViewModel: RootViewModel
  @StateObject private var viewModel: DeliveryTrackingViewModel
  
  @State private var pickupCoordinateItem: MKMapItem
  @State private var dropoffCoordinateItem: MKMapItem
  
  init(viewModel: DeliveryTrackingViewModel) {
    _pickupCoordinateItem = State(initialValue: MKMapItem(placemark: MKPlacemark(coordinate: viewModel.deliveryTask?.pickupAddress.clLocation.coordinate ?? .init())))
    _dropoffCoordinateItem = State(initialValue: MKMapItem(placemark: MKPlacemark(coordinate: viewModel.deliveryTask?.dropOffAddress.clLocation.coordinate ?? .init())))
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var body: some View {
    GeometryReader { geometry in
      // Map
      if let courier = viewModel.courierAnnotation,
         let deliveryTask = viewModel.deliveryTask,
         let pickupCoordinateItem = MKMapItem(placemark: MKPlacemark(coordinate: deliveryTask.pickupAddress.clLocation.coordinate)),
         let dropoffCoordinateItem = MKMapItem(placemark: MKPlacemark(coordinate: deliveryTask.dropOffAddress.clLocation.coordinate))
      {
        TrackingMapView(route: MapRoute(origin: pickupCoordinateItem, destination: dropoffCoordinateItem), courierAnnotation: courier, regionToCourierPublisher: viewModel.regionToCourierPublisher)
      } else {
        ZStack {
          Color.backgroundColor
          ProgressView()
        }
      }
      BottomSheetView(
        displayType: $viewModel.bottomSheetDisplayType,
        minimizedHeight: 200,
        maxHeight: geometry.size.height
      ) {
        ScrollView {
          VStack(alignment: .leading, spacing: 22) {
            // Courier details
            VStack(alignment: .leading) {
              Text("Courier").bold()
              HStack {
                WebImage(url: viewModel.courier?.profilePictureUrl)
                  .resizable()
                  .placeholder {
                    Image(systemName: "person.circle.fill")
                      .resizable()
                      .frame(width: 30, height: 30)
                      .foregroundColor(.gray)
                  }
                  .frame(width: 30, height: 30)
                  .clipShape(Circle())
                Text(viewModel.courier?.name ?? "Courier name")
                  .font(.subheadline)
                Spacer()
                Button(action: { viewModel.showingChatView = true }) {
                  Text("Chat")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .padding(5)
                    .padding(.horizontal)
                    .background(
                      RoundedRectangle(cornerRadius: 5)
                    )
                }
                .overlay {
                  if let courier = viewModel.courier {
                    NavigationLink(
                      isActive: $viewModel.showingChatView,
                      destination: {
                        LazyView(ChatRoomView(
                          userId: rootViewModel.customer!.id,
                          otherUserType: kCourierType,
                          otherUserProfilePictureUrl: courier.profilePictureUrl,
                          otherUserName: courier.name,
                          otherUserId: courier.id))
                      },
                      label: EmptyView.init)
                  }
                }
              }
              Text("Bike: \(viewModel.courier?.bikeBrand ?? "-") • \(viewModel.courier?.bikePlate ?? "-")")
                .font(.caption.bold())
                .foregroundColor(.secondary)
                .padding(.top, 4)
            }
            .lineLimit(1)
            .padding()
            .frame(height: 130)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
              RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .shadow(radius: 2)
            )
            
            // Status
            VStack(alignment: .leading) {
              Text("Delivery Status").bold()
              VStack(alignment: .leading, spacing: 0) {
                makeDeliveryStatusItem(status: viewModel.deliveryTask?.status![safe: 0]!
                                       ?? .init(status: .requestAccepted))
                makeStatusSeparatorLine()
                makeDeliveryStatusItem(status: viewModel.deliveryTask?.status![safe: 1]
                                       ?? .init(status: .itemsPickedUp))
                makeStatusSeparatorLine()
                makeDeliveryStatusItem(status: viewModel.deliveryTask?.status![safe: 2]
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
            
            // Route
            VStack(alignment: .leading, spacing: 8) {
              Text("Route").bold()
              PickupDestinationView(
                pickupAddress: viewModel.deliveryTask?.pickupAddress.geocodedLocation ?? .init(),
                pickupDetails: viewModel.deliveryTask?.pickupAddress.details ?? "-",
                destinationAddress: viewModel.deliveryTask?.dropOffAddress.geocodedLocation ?? .init(),
                destinationDetails: viewModel.deliveryTask?.dropOffAddress.details ?? "-"
              )
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
        .background(Color.backgroundColor)
        .redacted(reason: viewModel.courier == nil || viewModel.deliveryTask == nil ? .placeholder : [])
      }
    }
    .navigationTitle("Delivery Tracking")
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      setNavigationBarColor(
        withStandardColor: .backgroundColor,
        andScrollEdgeColor: .backgroundColor)
    }
    .onReceive(viewModel.$bottomSheetDisplayType, perform: { displayType in
      if displayType == .fullScreen {
        setNavigationBarColor(withStandardColor: .primaryColor, andScrollEdgeColor: .primaryColor)
      } else {
        setNavigationBarColor(withStandardColor: .backgroundColor, andScrollEdgeColor: .backgroundColor)
      }
    })
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: viewModel.onTapCourierFocusButton) {
          Image("two_wheeler")
            .renderingMode(.template)
            .resizable()
            .frame(width: 25, height: 25)
            .foregroundColor(.init(uiColor: .darkGray))
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
      .frame(width: 20, height: 20, alignment: .center)
      .foregroundColor(viewModel.deliveryTask?.status![safe: 1] == nil ? .secondary : .init(uiColor: .darkGray))
  }
  
  private func makeDeliveryStatusItem(status: DeliveryStatus) -> some View {
    HStack {
      if status.date != nil {
        ZStack {
          Circle()
            .fill(Color.primaryColor)
            .frame(width: 20, height: 20)
            .overlay {
              Text("\(Image(systemName: "checkmark"))")
                .font(.caption2.bold())
                .foregroundColor(.black)
            }
          Circle()
            .strokeBorder(Color(uiColor: .darkGray), lineWidth: 1.5)
            .frame(width: 20, height: 20)
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
            .frame(width: 20, height: 20)
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
  
  
}
