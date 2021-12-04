//
//  HomeView.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 30/11/21.
//

import SwiftUI

struct HomeView: View {
  @EnvironmentObject var mainViewModel: MainViewModel
  @State private var showingSignOutDialog = false
  @State private var showingEditProfile = false
  
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
