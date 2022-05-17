//
//  HomeView.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 30/11/21.
//

import SwiftUI
import MapKit
import Combine

struct HomeView: View {
  @Environment(\.scenePhase) private var scenePhase
  @EnvironmentObject var mainViewModel: MainViewModel
  @EnvironmentObject var drawerStateManager: DrawerStateManager
//  @StateObject private var viewModel: HomeViewModel
  @ObservedObject private var viewModel: HomeViewModel
  @State private var showingDrawerMenuView = false
  @State private var coordinateRegion: MKCoordinateRegion = .init(
    center: .init(),
    span: .init(latitudeDelta: 10, longitudeDelta: 10))
  
  static private var incomingViewModel: IncomingDeliveryViewModel!
  
  init(viewModel: HomeViewModel) {
//    _viewModel = StateObject(wrappedValue: viewModel)
    self.viewModel = viewModel
  }
  
  var body: some View {
    NavigationView {
      if viewModel.isOnDuty, let task = viewModel.onDutyTask {
        OnDutyView(
          homeViewModel: viewModel,
          viewModel: .init(
            courierId: mainViewModel.courier.id,
            initialDeliveryTask: task,
            deliveryTaskPublisher: viewModel.onDutyTaskPublisher)
        )
      } else {
        standbyView
          .background(
            NavigationLink(
              isActive: $showingDrawerMenuView,
              destination: {
                switch drawerStateManager.selectedMenu {
                case .chat:
                  LazyView(ConversationsView(viewModel: .init(userId: mainViewModel.courier.id)))
                case .tasks:
                  LazyView(DeliveryTaskHistoryView(viewModel: .init(courierId: mainViewModel.courier.id)))
                case .wallet:
                  LazyView(WalletDetailsView(viewModel: .init()))
                case .home: EmptyView()
                }
              },
              label: EmptyView.init)
          )
          .background(
            NavigationLink(
              isActive: $drawerStateManager.showingEditProfile,
              destination: {
                LazyView(EditProfileView(
                  viewModel: .init(mainViewModel: mainViewModel)
                ))
              },
              label: EmptyView.init)
          )
          .onReceive(drawerStateManager.$selectedMenu) { menu in
            showingDrawerMenuView = menu != .home
            drawerStateManager.hideView()
          }
      }
      
    }
  }
  
  private var standbyView: some View {
    Map(coordinateRegion: $coordinateRegion, showsUserLocation: true)
      .navigationTitle("Courier App")
      .navigationBarTitleDisplayMode(.inline)
      .ignoresSafeArea()
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(action: drawerStateManager.showView) {
            if !drawerStateManager.showingView {
              Image(systemName: "text.justify")
                .foregroundColor(.init(uiColor: .darkGray))
            }
          }
        }
      }
      .overlay(alignment: .top) {
        RoundedRectangle(cornerRadius: 8)
          .fill(Color.white)
          .frame(height: 85)
          .shadow(radius: 5)
          .overlay {
            HStack {
              VStack(alignment: .leading) {
                Text("Status")
                  .font(.subheadline)
                Text(viewModel.statusText)
                  .font(.headline)
                  .fontWeight(.bold)
              }
              Spacer()
              Toggle(isOn: $viewModel.isOnline, label: EmptyView.init)
            }
            .padding()
          }
          .padding()
      }
      .overlay(alignment: .bottom) {
        Text(viewModel.isOnline ? viewModel.onlineInfoText : viewModel.offlineInfoText)
          .font(.footnote)
          .foregroundColor(viewModel.isOnline ? .white : .black)
          .padding(.horizontal)
          .padding(.vertical, 10)
          .background(
            RoundedRectangle(cornerRadius: 10)
              .fill(Color.init(uiColor: viewModel.isOnline ? .darkGray : .white))
          )
          .padding(.bottom, 32)
          .animation(.easeIn, value: viewModel.isOnline)
      }
      .onAppear {
        setNavigationBarColor(withStandardColor: .backgroundColor, andScrollEdgeColor: .backgroundColor)
        if let coordinate = viewModel.currentCoordinate {
          print("\nCurrent coordinate: \(coordinate)\n")
          coordinateRegion = .init(center: coordinate,
                                   span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01))
        }
      }
      .onReceive(viewModel.$isOnline) { online in
        online
          ? viewModel.createSession(courierId: mainViewModel.courier.id)
          : viewModel.removeSession()
      }
      .onReceive(viewModel.incomingTaskPublisher) { task in
        print("\ntask: \(task)\n")
        guard let deadlineDate = task.deadlineConfirmationDate else {
          print("Deadlinedate == nil")
          return }
        Self.incomingViewModel = IncomingDeliveryViewModel(
          deadlineDate: deadlineDate,
          deliveryTask: task)
        viewModel.listenAcceptedTaskPublisher(Self.incomingViewModel.acceptedTaskPublisher)
        viewModel.showingIncomingTaskView = true
      }
      .fullScreenCover(
        isPresented: $viewModel.showingIncomingTaskView,
        onDismiss: {
//            Self.incomingViewModel = nil
        }
      ) {
        IncomingDeliveryView.init(viewModel: Self.incomingViewModel) {
          RouteMapView(route: MapRoute(
            origin: MKMapItem(placemark: MKPlacemark(coordinate: Self.incomingViewModel.deliveryTask.pickupAddress.clLocation.coordinate)),
            destination: MKMapItem(placemark: MKPlacemark(coordinate: Self.incomingViewModel.deliveryTask.dropOffAddress.clLocation.coordinate)))
          )
        }
      }
  }
  
  //
  
}


/*
struct HomeView: View {
  @EnvironmentObject var mainViewModel: MainViewModel
  @State private var showingSignOutDialog = false
  @State private var showingEditProfile = false
  
  init() {
    UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(named: "AccentColor")
  }
  
  var body: some View {
    NavigationView {
      LazyVStack(spacing: 35) {
        VStack {
          Image.appLogo
            .resizable()
            .frame(width: 100, height: 100)
          Text("Coming Soon 🙌🏼")
            .font(.title)
            .bold()
          Text("Features are still limited in this prototype")
            .foregroundColor(.secondary)
        }
        
        Button(action: { showingEditProfile = true }) {
          Text("Edit Profile")
            .bold()
            .frame(width: UIScreen.main.bounds.width * 0.8)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        
        NavigationLink(
          isActive: $showingEditProfile,
          destination: {
            LazyView(EditProfileView(
              viewModel: .init(mainViewModel: mainViewModel)
            ))
          },
          label: EmptyView.init
        )
        
      }
      
      .frame(height: UIScreen.main.bounds.height)
      .overlay(alignment: .bottom) {
        Button(action: { showingSignOutDialog = true }) {
          Text("Sign Out")
            .frame(width: UIScreen.main.bounds.width * 0.8)
        }
        .buttonStyle(.bordered)
        .tint(.red)
        .controlSize(.large)
        .padding(.bottom, 40)
      }
      .ignoresSafeArea()
      .background(Color.backgroundColor)
      .navigationTitle("Courier App")
      .confirmationDialog(
        "Are you sure want to sign out?",
        isPresented: $showingSignOutDialog,
        titleVisibility: .visible
      ) {
        Button("Sign Out", role: .destructive) {
          AuthenticationService.shared.signOut()
          NotificationCenter.default.post(
            name: .signInRequiredNotification,
            object: nil
          )
        }
        Button("Cancel", role: .cancel) {
          showingSignOutDialog = false
        }
        .tint(.accentColor)
      }
      
    }
    
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView()
  }
}
*/
