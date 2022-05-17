//
//  RequestDeliveryView.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 05/04/22.
//

import SwiftUI
import MapKit

struct RequestDeliveryView: View {
  @EnvironmentObject var mainViewModel: MainViewModel
  @StateObject private var viewModel: RequestDeliveryViewModel
  @Environment(\.dismiss) var dismiss
  
  init(viewModel: RequestDeliveryViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var body: some View {
    NavigationView {
      VStack(alignment: .leading) {
        RouteMapView(
          totalDistance: $viewModel.totalDistance,
          totalTravelTime: $viewModel.totalTravelTime,
          route: MapRoute(
            origin: viewModel.originMapItem,
            destination: viewModel.destinationMapItem),
          mapRegionToPickUpPublisher: viewModel.mapRegionToPickUpPublisher,
          mapVisibleRectToInitialPublisher: viewModel.mapVisibleRectToInitialPublisher
        )
          .frame(height: UIScreen.main.bounds.height * 0.45)
          .overlay {
            if viewModel.isLookingForCourier {
              RippleView(
                initialDiameter: UIScreen.main.bounds.width*0.25,
                finalDiameter: UIScreen.main.bounds.width
              ).opacity(0.6)
            }
          }
          .overlay(alignment: .bottomTrailing) {
            if !viewModel.isLookingForCourier {
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
          }
        
        VStack(alignment: .leading, spacing: 22) {
          Text(viewModel.totalDistanceText)
            .foregroundColor(.black)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(
              RoundedRectangle(cornerRadius: 8)
                .fill(Color.backgroundColor)
                .shadow(radius: 4)
            )
            .frame(maxWidth: .infinity)
            .padding(.top, -30)
          
          ScrollView {
            RouteDetailsView(pickupAddress: viewModel.pickupAddress, pickupDetails: viewModel.pickupDetails, destinationAddress: viewModel.destinationAddress, destinationDetails: viewModel.destinationDetails)
          }
          .padding(.top)
          
          Button(action: onTapRequestDeliveryButton) {
            RoundedRectangle(cornerRadius: 8)
              .frame(height: 44)
              .overlay {
                if viewModel.isLookingForCourier {
                  ProgressView().tint(.white)
                } else {
                  Text("Request Delivery").foregroundColor(.white)
                }
              }
          }
          .disabled(viewModel.isLookingForCourier)
        }
        .padding()
        .background(
          Rectangle()
            .fill(Color.white)
            .shadow(radius: 5)
        )
      }
      .onAppear {
        setNavigationBarColor(withStandardColor: .secondaryColor,
                              andScrollEdgeColor: .secondaryColor)
      }
      .navigationBarTitleDisplayMode(.inline)
      .navigationTitle(viewModel.title)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(action: dismiss.callAsFunction) {
            Image(systemName: "xmark")
          }
          .disabled(viewModel.isLookingForCourier)
        }
      }
      .sheet(isPresented: $viewModel.showingCourierNotFoundError) {
        ourierNotAvailableView
      }
      .alert(
        viewModel.courierFoundText,
        isPresented: $viewModel.showingCourierFound
      ) {
        Button("Ok", action: viewModel.onDismissCourierFoundAlert) 
      }
//      .alert(isPresented: $viewModel.showingCourierFound) {
//        Alert(title: Text(viewModel.courierFoundText),
//              dismissButton: Alert.Button)
//      }
    }
  }
  
  func onTapRequestDeliveryButton() {
    viewModel.requestDelivery(merchant: mainViewModel.merchant)
  }
}

private extension RequestDeliveryView {
  struct RouteDetailsView: View {
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
            .font(.subheadline)
            .padding(.leading, 30)
          HStack(alignment: .top, spacing: 10) {
            VStack {
              Image(systemName: "circle.circle")
                .font(.subheadline.bold())
              VLine()
                .stroke(style: StrokeStyle(
                  lineWidth: 1,
                  dash: [5])
                )
            }
            .frame(
              width: 20,
              height: pickupLocationVLineSize.height
            )
            VStack(alignment: .leading) {
              Text(pickupAddress)
                .bold()
              Text("Details: \(pickupDetails.isEmpty ? "-" : pickupDetails)")
                .font(.footnote)
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
            Text("Destination Location")
              .font(.subheadline)
              .readSize { destinationLocationVLineSize = $0 }
          }
          HStack(alignment: .top, spacing: 10) {
            Image(systemName: "mappin.and.ellipse")
              .font(.subheadline.bold())
              .frame(width: 20)
            VStack(alignment: .leading) {
              Text(destinationAddress)
                .bold()
              Text("Details: \(destinationDetails.isEmpty ? "-" : destinationDetails)")
                .font(.footnote)
            }
          }
        }
      }
    }
  }
}

private extension RequestDeliveryView {
  var ourierNotAvailableView: some View {
    let imageWidth = UIScreen.main.bounds.width * 0.25
    return VStack {
      Spacer()
      VStack(spacing: 0) {
        Image("location")
          .resizable()
          .frame(width: imageWidth, height: imageWidth)
          .padding(.bottom)
        Text("Couldn't find a courier.")
          .bold()
          .font(.title)
      }
      Spacer()
      VStack {
        Button(action: {
          viewModel.showingCourierNotFoundError = false
          viewModel.requestDelivery(merchant: mainViewModel.merchant)
        }) {
          RoundedRectangle(cornerRadius: 8)
            .strokeBorder(lineWidth: 2)
            .frame(height: 44)
            .overlay {
              Text("Try Again")
            }
        }
        Button(action: {
          viewModel.showingCourierNotFoundError = false
        }) {
          RoundedRectangle(cornerRadius: 8)
            .strokeBorder(Color.clear, lineWidth: 2)
            .frame(height: 44)
            .overlay {
              Text("Cancel")
            }
        }
      }
    }
    .padding()
//    .frame(height: UIScreen.main.bounds.height * 0.4)
    .background(
      Rectangle()
        .fill(Color.white)
    )
    
  }
}

extension RequestDeliveryViewModel {
  var originMapItem: MKMapItem {
    MKMapItem(placemark: MKPlacemark(coordinate: pickupGeoCooordinate))
  }
  var destinationMapItem: MKMapItem {
    MKMapItem(placemark: MKPlacemark(coordinate: destinationGeoCoordinate))
  }
}
