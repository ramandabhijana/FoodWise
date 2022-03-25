//
//  DonationDetailsView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 15/03/22.
//

import SwiftUI
import SDWebImageSwiftUI
import CoreLocation
import MapKit

struct DonationDetailsView: View {
  @StateObject private var viewModel: DonationDetailsViewModel
  @State private var currentNavBarConfig: CurrentNavigationBarConfiguration = .init()
  @State private var imageOffset: CGFloat = 0.0
  @State private var tabBar: UITabBar?
  @State private var tabBarHeight: CGFloat?
  @FocusState private var messageFieldFocused: Bool
  
  @Environment(\.dismiss) private var dismiss
  @Environment(\.safeAreaInsets) private var safeAreaInsets
  
  private let imageHeight: CGFloat
  private let transparentBarThreshold: CGFloat
  
  init(viewModel: DonationDetailsViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
    let imageHeight = UIScreen.main.bounds.height * 0.4
    self.imageHeight = imageHeight
    self.transparentBarThreshold = -imageHeight * 0.74
  }
  
  var body: some View {
    ScrollView(showsIndicators: false) {
      VStack(alignment: .leading) {
        WebImage(url: viewModel.donation.pictureUrl)
          .resizable()
          .scaledToFill()
          .frame(width: UIScreen.main.bounds.width, height: imageHeight)
          .clipped()
          .onTapGesture {
            viewModel.showingPhotoViewer = true
          }
          .overlay(alignment: .top) {
            GeometryReader { proxy -> Color in
              let minY = proxy.frame(in: .global).minY
              DispatchQueue.main.async {
                imageOffset = minY
                withAnimation {
                  currentNavBarConfig.setColor(imageOffset < transparentBarThreshold
                                               ? .primaryColor
                                               : .clear)
                }
              }
              return .clear
            }.frame(width: 0, height: 0)
          }
        
        VStack(alignment: .leading, spacing: 20) {
          VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.donation.kindValue.rawValue.uppercased())
              .font(.subheadline)
              .bold()
              .foregroundColor(.secondary)
            Text(viewModel.donation.foodName)
              .font(.title)
              .bold()
          }
          .padding(.bottom)
          
          VStack(alignment: .leading, spacing: 8) {
            Text("Shared by").bold()
            HStack(spacing: 15) {
              WebImage(url: viewModel.sharer.profileImageUrl)
                .resizable()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
              Text(viewModel.isDonatedByCurrentCustomer ? "You" : viewModel.sharer.fullName)
              Spacer()
              if !viewModel.isDonatedByCurrentCustomer {
                Button(action: {  }) {
                  Text("Chat")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 5)
                    .overlay {
                      RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(lineWidth: 2)
                    }
                }
              }
            }
          }
          .padding(.bottom)
          
          
          VStack(alignment: .leading, spacing: 5) {
            HStack {
              Text("Pick up Location").bold()
              Spacer()
              Button("View on map", action: { viewModel.showingMapView = true })
              .font(.subheadline)
            }
            HStack(alignment: .center, spacing: 8) {
              VStack(alignment: .leading) {
                Text(viewModel.donation.pickupLocation.geocodedLocation)
                Text("Details: \(viewModel.donation.pickupLocation.details)")
                  .font(.footnote)
              }
            }
          }
          .padding(.bottom)
          
          VStack(alignment: .leading) {
            Text("Note").bold()
            Text(viewModel.donation.notes.isEmpty ? "-" : viewModel.donation.notes)
              .font(.footnote)
          }
        }
        .padding()
      }
      .padding(.bottom, 80)
    }
    .onAppear {
      NotificationCenter.default.post(
        name: .tabBarHiddenNotification,
        object: nil)
    }
    .onDisappear {
      tabBar?.isHidden = false
//      NotificationCenter.default.post(
//        name: .tabB,
//        object: nil)
    }
    .navigationBarHidden(true)
    .background(Color.backgroundColor)
    .ignoresSafeArea()
    .toolbar {
      ToolbarItem(placement: .keyboard) {
        HStack {
          Spacer()
          Button("Done") {
            messageFieldFocused = false
          }
        }
      }
    }
    .sheet(isPresented: $viewModel.showingMapView) {
      mapView
    }
    .snackBar(
      isShowing: $viewModel.showingErrorSnackbar,
      text: Text("Something went wrong"),
      isError: true
    )
    .snackBar(
      isShowing: $viewModel.showingSendingSnackbar,
      text: Text("Sending request")
    )
    .alert(isPresented: $viewModel.showingSuccessAlert) {
      Alert(title: Text("Request sent!"),
            message: Text("We'll send you an email if the request is accepted"),
            dismissButton: .default(Text("Ok")))
    }
    .introspectTabBarController(customize: { tabBarController in
      tabBar = tabBarController.tabBar
      tabBar?.isHidden = true
      
//      tabBarHeight = (tabBarController.tabBar.frame.height) - safeAreaInsets.bottom
      // (tabBar?.frame.height ?? 0.0) - safeAreaInsets.bottom
      
//      tabBarHeight = (tabBar?.frame.height ?? 0.0) - safeAreaInsets.bottom
      
//      tabBar?.frame = .zero
    })
    .overlay(alignment: .top) {
      navigationBar
    }
    .overlay(alignment: .bottom) {
      if !viewModel.isDonatedByCurrentCustomer {
        Rectangle()
          .fill(Color.secondaryColor)
          .shadow(radius: 5)
          .edgesIgnoringSafeArea(.bottom)
          .frame(height: 80)
          .overlay {
            Button(action: { viewModel.showingMessageSheet = true }) {
              RoundedRectangle(cornerRadius: 8)
                .fill(Color.accentColor)
                .frame(height: 44)
                .padding(.horizontal)
                .overlay {
                  Text(
                    viewModel.donation.status == DonationStatus.available.rawValue
                    ? "Send Request" : "Not available"
                  )
                    .foregroundColor(.white)
                }
            }
            .disabled(viewModel.donation.status != DonationStatus.available.rawValue)
          }
          .offset(y: tabBarHeight ?? 0.0)
          .offset(y: (tabBar?.frame.height ?? 0.0) - safeAreaInsets.bottom)
      }
    }
    
    .overlay {
      VStack {
        Spacer()
        RoundedRectangle(cornerRadius: 16)
          .fill(Color.white)
          .frame(height: 350)
          .shadow(radius: 20)
          .overlay(alignment: .topLeading) {
            VStack(alignment: .leading) {
              Button("\(Image(systemName: "xmark"))") {
                viewModel.showingMessageSheet = false
              }
              .padding(.bottom)
              Text("Let the sharer know why you want to get the food (optional)")
                .font(.subheadline)
              TextEditor(text: $viewModel.messageText)
                .border(Color.secondary)
                .focused($messageFieldFocused)
              Button(action: { viewModel.sendRequest() }) {
                RoundedRectangle(cornerRadius: 10)
                  .frame(height: 44)
                  .overlay {
                    Text("Send").foregroundColor(.white)
                  }
              }
              .padding(.top, 48)
            }
            .padding()
            .padding(.bottom)
          }
          .animation(.easeIn, value: viewModel.showingMessageSheet)
      }
      .offset(y: (tabBar?.frame.height ?? 0.0) - safeAreaInsets.bottom)
      .background(Color.black.opacity(0.4))
      .offset(y: viewModel.showingMessageSheet ? 0 : UIScreen.main.bounds.height)
    }
    
  }
  
//  private func openLocationInMaps() {
//    let regionDistance: CLLocationDistance = 0.1
//    let coordinate: CLLocationCoordinate2D = viewModel.donation.pickupLocation.clLocation.coordinate
//    let regionSpan = MKCoordinateRegion(
//      center: coordinate,
//      latitudinalMeters: regionDistance,
//      longitudinalMeters: regionDistance)
//    let options = [
//      MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
//      MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
//    ]
//    let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
//    let mapItem = MKMapItem(placemark: placemark)
//    mapItem.openInMaps(launchOptions: options)
//  }
  
}

//struct DonationDetailsView_Previews: PreviewProvider {
//  static var previews: some View {
//    DonationDetailsView()
//  }
//}

private extension DonationDetailsView {
  var navigationBar: some View {
    Rectangle()
      .fill(Color.clear)
      .background(navigationBarBackground)
      .edgesIgnoringSafeArea(.top)
      .frame(height: 48)
      .overlay(alignment: .top) {
        HStack {
          backButton
          Spacer()
        }
//        .padding(.top, 48)
//        .padding(.top, safeAreaInsets.top)
        .padding(.horizontal)
        .padding(.bottom, currentNavBarConfig.isTransparent ? 20 : 5)
      }
  }
  
  private var backButton: some View {
    let imageName = "chevron.backward"
    return VStack {
      Button(
        action: { dismiss() },
        label: {
          Image(systemName: imageName)
            .foregroundColor(.init(uiColor: .darkGray))
            .font(.title3)
        })
    }
//    .frame(width: width * 0.08, height: width * 0.08)
    .padding(5)
    .background(currentNavBarConfig.isTransparent ? Color.white : .clear)
    .clipShape(Circle())
  }
  
  @ViewBuilder private var navigationBarBackground: some View {
    if !currentNavBarConfig.isTransparent {
      Color.primaryColor
    } else {
      LinearGradient(
        gradient: Gradient(
          stops: [
            .init(color: .black.opacity(0.4), location: 0.1),
            .init(color: .clear, location: 0.85)
          ]),
        startPoint: .top,
        endPoint: .bottom)
    }
  }
  
  var mapView: some View {
    NavigationView {
      CoordinateMapViewerView(
        region: .init(
          center: viewModel.donation.pickupLocation.clLocation.coordinate,
          span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ),
        coordinates: [viewModel.donation.pickupLocation.clLocation.coordinate]
      )
        .navigationTitle("Pick up Location")
        .navigationBarTitleDisplayMode(.inline)
    }
  }
  
}

enum CurrentNavigationBarState {
  case transparent
  case opaque
}

struct CurrentNavigationBarConfiguration {
  private(set) var color: Color
  private var state: CurrentNavigationBarState
  var isTransparent: Bool { color == .clear }
  
  init() {
    color = .clear
    state = .transparent
  }
  
  mutating func setColor(_ color: Color) {
    guard color != self.color else { return }
    self.color = color
    state = isTransparent ? .transparent : .opaque
  }
}
