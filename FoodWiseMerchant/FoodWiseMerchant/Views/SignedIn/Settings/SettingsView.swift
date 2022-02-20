//
//  SettingsView.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 01/12/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct SettingsView: View {
  @EnvironmentObject var mainViewModel: MainViewModel
  @State private var image: Image? = nil
  @State private var showingEditProfileView = false
  @State private var showingSignOutDialog = false
  
  var body: some View {
    ScrollView(showsIndicators: false) {
      VStack {
        VStack(spacing: 24) {
          WebImage(url: mainViewModel.merchant.logoUrl)
            .resizable()
            .placeholder {
              Circle()
                .fill(Color(uiColor: .lightGray).opacity(0.6))
                .frame(width: 100, height: 100)
                .overlay {
                  ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .tint(.white)
                }
            }
            .frame(width: 100, height: 100)
            .clipShape(Circle())
          
          VStack {
            Text(mainViewModel.merchant.name).fontWeight(.semibold)
            Text(mainViewModel.merchant.storeType)
            Text(mainViewModel.merchant.location.geocodedLocation)
          }
          NavigationLink(
            isActive: $showingEditProfileView,
            destination: {
              LazyView(
                EditProfileView(
                  showingSelf: $showingEditProfileView,
                  viewModel: .init(mainViewModel: mainViewModel)
                )
              )
            },
            label: {
              RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.accentColor, lineWidth: 3)
                .frame(height: 44)
                .overlay {
                  Text("Edit Profile")
                }
            }
          )
//          NavigationLink {
//            LazyView(
//              EditProfileView(viewModel: .init(mainViewModel: mainViewModel))
//            )
//          } label: {
//            RoundedRectangle(cornerRadius: 10)
//              .strokeBorder(Color.accentColor, lineWidth: 3)
//              .frame(height: 44)
//              .overlay {
//                Text("Edit Profile")
//              }
//          }
        }
        .padding(.horizontal)
        .frame(
          width: UIScreen.main.bounds.width * 0.9
        )
        .padding(.vertical)
        .background(Color.backgroundColor)
        .cornerRadius(10)
        
        Spacer()
        
        Button(action: { showingSignOutDialog.toggle() }) {
          HStack {
            Image(systemName: "rectangle.portrait.and.arrow.right")
              .rotation3DEffect(.degrees(180), axis: (x: 0, y:1, z: 0))
            Text("Sign Out").padding(.leading)
          }
          .foregroundColor(.black)
        }
        
      }
      .frame(height: UIScreen.main.bounds.height * 0.65)
      .padding(.vertical)
      
    }
    .frame(maxWidth: .infinity)
    .background(Color.primaryColor)
    .edgesIgnoringSafeArea(.bottom)
    .overlay(alignment: .bottom) {
      Image.footerFoods
        .resizable()
        .aspectRatio(contentMode: .fit)
        .opacity(0.2)
        .offset(y: 30)
    }
    .navigationBarTitleDisplayMode(.large)
    .navigationTitle("Settings")
    .confirmationDialog(
      "Are you sure want to sign out?",
      isPresented: $showingSignOutDialog,
      titleVisibility: .visible
    ) {
      Button("Sign Out", role: .destructive, action: signOut)
      Button("Cancel", role: .cancel) {
        showingSignOutDialog.toggle()
      }
    }
  }
  
  private func signOut() {
    AuthenticationService.shared.signOut()
    NotificationCenter.default.post(name: .signInRequiredNotification,
                                    object: nil)
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView()
  }
}
