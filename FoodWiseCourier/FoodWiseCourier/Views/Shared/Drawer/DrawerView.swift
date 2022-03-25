//
//  DrawerView.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 16/03/22.
//

import SwiftUI
import SDWebImageSwiftUI

enum CourierDrawerMenu: String, CaseIterable {
  case home = "Home"
  case chat = "Chat"
  case tasks = "Tasks"
  case wallet = "Wallet"
}

extension CourierDrawerMenu {
  var imageSystemName: String {
    switch self {
    case .home: return "house.fill"
    case .chat: return "text.bubble.fill"
    case .tasks: return "paperplane.fill"
    case .wallet: return "banknote.fill"
    }
  }
}

class DrawerStateManager: ObservableObject {
  @Published var selectedMenu: CourierDrawerMenu = .home
  @Published var showingView = false
  
  func showView() {
    showingView = true
  }
  
  func hideView() {
    showingView = false
  }
}

struct DrawerView: View {
  @EnvironmentObject var mainViewModel: MainViewModel
  @ObservedObject var manager: DrawerStateManager
  @State private var showingSignOutDialog = false
  
  var body: some View {
//    NavigationView {
      VStack {
        HStack(alignment: .top) {
          WebImage(url: mainViewModel.courier.profilePictureUrl)
            .resizable()
            .placeholder {
              Circle()
                .fill(Color(uiColor: .lightGray).opacity(0.6))
                .frame(width: 50, height: 50)
                .overlay {
                  Image(systemName: "person.circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, Color(uiColor: .lightGray).opacity(0.5))
                    .font(.system(size: 50))
                }
            }
            .aspectRatio(contentMode: .fill)
            .frame(width: 50, height: 50)
            .clipShape(Circle())
          
          Spacer()
          Button(action: manager.hideView) {
            Image(systemName: "xmark")
              .font(.title2)
              .foregroundColor(.init(uiColor: .darkGray))
          }
        }
        .padding()
        
        VStack(alignment: .leading, spacing: 0) {
          Text("COURIER")
            .font(.callout)
            .foregroundColor(.secondary)
          HStack(alignment: .bottom, spacing: 16) {
            Text(mainViewModel.courier.name)
              .font(.title3)
              .fontWeight(.bold)
            Spacer()
            NavigationLink(destination: {
              LazyView(EditProfileView(
                viewModel: .init(mainViewModel: mainViewModel)
              ))
            }, label: {
              Text("Edit")
                .fontWeight(.bold)
                .font(.callout)
            })
          }
          
        }
        // to make it aligned to leading edge
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        
        VStack(spacing: 16) {
          ForEach(CourierDrawerMenu.allCases, id: \.rawValue) { menu in
            DrawerMenuButton(
              menu: menu,
              currentSelectedMenu: $manager.selectedMenu
            )
          }
        }
        .padding(.leading)
        .frame(width: 250, alignment: .leading)
        .padding(.top, 30)
        
        Divider()
          .padding(.top, 30)
          .padding(.horizontal, 25)
        
        Spacer()
        
        signOutButton
          .padding(.bottom)
      }
      .frame(width: 250)
      .background(Color.secondaryColor)
      .navigationBarHidden(true)
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
  
  private var signOutButton: some View {
    Button(action: { showingSignOutDialog = true }) {
      HStack(spacing: 15) {
        Image(systemName: "rectangle.righthalf.inset.fill.arrow.right")
          .font(.title2)
          .foregroundColor(.init(uiColor: .darkGray))
        Text("Sign Out")
          .foregroundColor(.init(uiColor: .darkGray))
      }
      .padding(.vertical, 12)
      .frame(width: 200, alignment: .leading)
    }
  }
  
  
}
