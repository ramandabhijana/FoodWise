//
//  NearbyView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 05/11/21.
//

import SwiftUI
import Combine

struct NearbyView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel: NearbyViewModel
  @State private var height: CGFloat = .zero
  
  private static var mapViewModel: NearbyMapViewModel!
  private static var listViewModel: NearbyListViewModel!
  
  private var radiusChangedSubject = PassthroughSubject<NearbyRadius, Never>()
  private var radiusChangedPublisher: AnyPublisher<NearbyRadius, Never> {
    radiusChangedSubject.eraseToAnyPublisher()
  }
  
  init(viewModel: NearbyViewModel) {
    let segmentedAppearance = UISegmentedControl.appearance()
    segmentedAppearance.selectedSegmentTintColor = .darkGray
    segmentedAppearance.setTitleTextAttributes(
      [.foregroundColor: UIColor.white],
      for: .selected)
    
    _viewModel = StateObject(wrappedValue: viewModel)
    Self.mapViewModel = NearbyMapViewModel(
      radiusChangedSubject: radiusChangedSubject,
      filteredMerchantsPublisher: viewModel.filteredMerchantsPublisher)
    Self.listViewModel = NearbyListViewModel(
      radiusChangedSubject: radiusChangedSubject,
      filteredMerchantsPublisher: viewModel.filteredMerchantsPublisher)
    
    NotificationCenter.default.post(
      name: .tabBarHiddenNotification,
      object: nil)
  }
  
  var body: some View {
    ZStack(alignment: .top) {
      switch viewModel.viewMode {
      case .map: NearbyMapView(viewModel: Self.mapViewModel)
      case .list: NearbyListView(viewModel: Self.listViewModel).padding(.top, 130)
      }
      VStack(spacing: 16) {
        HStack {
          Button(action: dismiss.callAsFunction) {
            Image(systemName: "chevron.backward")
              .font(.title2)
              .foregroundColor(.black)
          }
          Spacer()
          Text(viewModel.currentLocationString)
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
      .padding(.top)
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
      .padding(.top, 48)
      .frame(height: 120)
    }
    .navigationBarHidden(true)
    .edgesIgnoringSafeArea(.top)
    .onReceive(radiusChangedPublisher) { radius in
      viewModel.onRadiusChanged(radius: radius)
    }
    .onDisappear {
      NotificationCenter.default.post(
        name: .tabBarShownNotification,
        object: nil)
    }
  }
  
  
}

struct NearbyView_Previews: PreviewProvider {
  static var previews: some View {
    NearbyView(viewModel: .init())
  }
}
