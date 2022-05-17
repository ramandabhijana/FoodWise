//
//  IncomingDeliveryView.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 09/04/22.
//

import SwiftUI
import SDWebImageSwiftUI
import MapKit

struct IncomingDeliveryView<Content: View>: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel: IncomingDeliveryViewModel
  @EnvironmentObject var mainViewModel: MainViewModel
  
  private let origin: MKMapItem
  private let destination: MKMapItem
  private let routeMapView: () -> Content
  
  init(viewModel: IncomingDeliveryViewModel, @ViewBuilder routeMapView: @escaping () -> Content) {
    _viewModel = StateObject(wrappedValue: viewModel)
    self.routeMapView = routeMapView
    self.origin = MKMapItem(placemark: MKPlacemark(coordinate: viewModel.deliveryTask.pickupAddress.clLocation.coordinate))
    self.destination = MKMapItem(placemark: MKPlacemark(coordinate: viewModel.deliveryTask.dropOffAddress.clLocation.coordinate))
  }
  
  var body: some View {
    NavigationView {
      VStack {
        VStack {
          Rectangle()
            .fill(Color.accentColor)
            .frame(
              width: UIScreen.main.bounds.width * CGFloat(viewModel.progressWidthScaleFactor),
              height: 3
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .animation(.easeIn, value: viewModel.progressWidthScaleFactor)
          
          Text(viewModel.timeElapsedText)
            .font(.footnote)
        }
        
        ScrollView {
          VStack(spacing: 22) {
            routeMapView()
              .shadow(radius: 2)
              .frame(height: UIScreen.main.bounds.height * 0.4)
            
            Button(action: { viewModel.showingRouteSheet = true }) {
              Text("View Route")
                .font(.subheadline)
                .bold()
                .padding(.vertical, 10)
                .frame(width: UIScreen.main.bounds.width * 0.48)
                .background(
                  ZStack {
                    RoundedRectangle(cornerRadius: 8)
                      .fill(Color.white)
                    RoundedRectangle(cornerRadius: 8)
                      .strokeBorder(lineWidth: 3)
                  }
                )
            }
            .padding(.top, -35)
            
            HStack {
              makeDeliveryDetailsItem(title: "Time", content: viewModel.timeFormatted)
              Spacer()
              makeDeliveryDetailsItem(title: "Service Wage", content: viewModel.wageFormatted)
              Spacer()
              makeDeliveryDetailsItem(title: "Distance", content: viewModel.distanceFormatted)
            }
            .padding()
            .background(
              RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .shadow(radius: 2)
            )
            
            // Route details
            VStack(alignment: .leading, spacing: 0) {
              Text("Route Details")
                .font(.headline)
                .padding(.bottom)
              RouteDetailsView(pickupAddress: viewModel.deliveryTask.pickupAddress.geocodedLocation, pickupDetails: viewModel.deliveryTask.pickupAddress.details, destinationAddress: viewModel.deliveryTask.dropOffAddress.geocodedLocation, destinationDetails: viewModel.deliveryTask.dropOffAddress.details)
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
                .font(.headline)
              HStack {
                WebImage(url: URL(string: viewModel.deliveryTask.requesterProfilePicUrl))
                  .resizable()
                  .placeholder {
                    Image(systemName: "person.circle.fill")
                      .resizable()
                      .foregroundColor(.secondary)
                      .frame(width: 22, height: 22)
                  }
                  .frame(width: 22, height: 22)
                  .clipShape(Circle())
                Text(viewModel.deliveryTask.requesterName)
                Spacer()
              }
            }
            .padding()
            .background(
              RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .shadow(radius: 2)
            )
          }
          .padding()
          .padding(.bottom, 70)
        }
      }
      .onReceive(viewModel.$shouldDismissView, perform: { dismiss in
        if dismiss { self.dismiss.callAsFunction() }
      })
      .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification), perform: { _ in
        viewModel.invalidateTimer()
      })
      .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification), perform: { _ in
        viewModel.resetTimerIfNotPassingDeadline()
      })
      .alert("Time's up!", isPresented: $viewModel.showingTimeIsUp) {
        Button("Dismiss", action: dismiss.callAsFunction)
      }
      .sheet(isPresented: $viewModel.showingRouteSheet) {
        NavigationView {
          routeMapView()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
              ToolbarItem(placement: .navigationBarLeading) {
                Button("Close") {
                  viewModel.showingRouteSheet = false
                }
              }
            }
        }
      }
      .overlay(alignment: .bottom) {
        ZStack {
          Rectangle()
            .fill(Color.secondaryColor)
            .shadow(radius: 5)
            .edgesIgnoringSafeArea(.bottom)
          HStack {
            Button {
              viewModel.rejectTask(courierId: mainViewModel.courier.id)
            } label: {
              ZStack {
                RoundedRectangle(cornerRadius: 8)
                  .fill(Color.errorColor)
                Text("Reject").bold()
                  .foregroundColor(.white)
              }
            }
            Button {
              viewModel.acceptTask(courierId: mainViewModel.courier.id)
            } label: {
              ZStack {
                RoundedRectangle(cornerRadius: 8)
                Text("Accept").bold()
                  .foregroundColor(.white)
              }
            }
          }
          .frame(height: 44)
          .padding()
          .padding(.bottom)
        }
        .frame(height: 44)
      }
      .navigationBarTitleDisplayMode(.inline)
      .navigationTitle("Incoming Delivery Task")
      .background(Color.backgroundColor)
    }
  }
  
  private func makeDeliveryDetailsItem(title: String, content: String) -> some View {
    VStack {
      Text(title)
        .font(.subheadline)
        .fontWeight(.light)
      Text(content)
        .bold()
        .lineLimit(1)
    }
  }
}

//struct IncomingDeliveryView_Previews: PreviewProvider {
//  static var previews: some View {
//    IncomingDeliveryView()
//  }
//}
