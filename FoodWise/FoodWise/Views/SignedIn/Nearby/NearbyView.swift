//
//  NearbyView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 05/11/21.
//

import SwiftUI
import Combine
import Introspect

struct NearbyView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.safeAreaInsets) private var safeAreaInsets
  @StateObject private var viewModel: NearbyViewModel
  @State private var hasAuthorized = true
  @State private var navigationBarSize = CGSize()
  
  private static var mapViewModel: NearbyMapViewModel!
  private static var listViewModel: NearbyListViewModel!
  
  private let locationAuthStatusPublisher = LocationManager.shared.authStatusPublisher
  
  private var radiusChangedSubject = PassthroughSubject<NearbyRadius, Never>()
  private var radiusChangedPublisher: AnyPublisher<NearbyRadius, Never> {
    radiusChangedSubject.eraseToAnyPublisher()
  }
  
  init(viewModel: NearbyViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
    Self.mapViewModel = NearbyMapViewModel(
      radiusChangedSubject: radiusChangedSubject,
      filteredMerchantsPublisher: viewModel.filteredMerchantsPublisher)
    Self.listViewModel = NearbyListViewModel(
      radiusChangedSubject: radiusChangedSubject,
      filteredMerchantsPublisher: viewModel.filteredMerchantsPublisher)
  }
  
  var body: some View {
    if !hasAuthorized {
      ZStack(alignment: .center) {
        Color.backgroundColor
        Text("This feature requires location authorization to be allowed.\nYou can change it on the device's settings")
      }
      .navigationBarHidden(false)
      .ignoresSafeArea()
      .onAppear {
        NotificationCenter.default.post(
          name: .tabBarHiddenNotification,
          object: nil)
      }
//      .onDisappear {
//        NotificationCenter.default.post(
//          name: .tabBarShownNotification,
//          object: nil)
//      }
    } else {
      ZStack(alignment: .top) {
        switch viewModel.viewMode {
        case .map: NearbyMapView(viewModel: Self.mapViewModel)
        case .list: NearbyListView(viewModel: Self.listViewModel).padding(.top, navigationBarSize.height)
        }
        
        VStack(spacing: 16) {
          HStack {
            Button(action: dismiss.callAsFunction) {
              Image(systemName: "chevron.backward")
                .font(.title2)
                .foregroundColor(.black)
            }
            Spacer()
            Text(viewModel.currentLocationString ?? "Loading location...")
              .bold()
              .font(.headline)
            Spacer()
          }
          Picker("Select view mode", selection: $viewModel.viewMode) {
            Text("Map").tag(NearbyViewModel.ViewMode.map)
            Text("List").tag(NearbyViewModel.ViewMode.list)
          }.pickerStyle(.segmented)
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.top, safeAreaInsets.top)
        .background(
          viewModel.viewMode == .map
          ? LinearGradient.navigationBarBackgroundColor
          : .init(colors: [.clear], startPoint: .top, endPoint: .bottom)
        )
        .padding(.bottom, 8)
        .background(
          viewModel.viewMode == .list
          ? Color.primaryColor
          : .clear
        )
        .readSize { navigationBarSize = $0 }
      }
      .navigationBarHidden(true)
      .edgesIgnoringSafeArea(.top)
      .onReceive(locationAuthStatusPublisher) { status in
        hasAuthorized = !(status == .denied || status == .restricted)
      }
      .onReceive(radiusChangedPublisher) { radius in
        viewModel.onRadiusChanged(radius: radius)
      }
      .onAppear {
        NotificationCenter.default.post(
          name: .tabBarHiddenNotification,
          object: nil)
      }
    }
  }
  
  
}

struct NearbyView_Previews: PreviewProvider {
  static var previews: some View {
    NearbyView(viewModel: .init())
  }
}
