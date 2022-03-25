//
//  MyProfileView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 31/10/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct MyProfileView: View {
  @EnvironmentObject var rootViewModel: RootViewModel
  @State private var showingSignOutDialog = false
  
  var body: some View {
    NavigationView {
      if let customer = rootViewModel.customer {
        ScrollView(showsIndicators: false) {
          LazyVStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 25) {
              HStack {
                WebImage(url: customer.profileImageUrl)
                  .resizable()
                  .scaledToFill()
                  .frame(width: 55, height: 55)
                  .clipShape(Circle())
                
                VStack(alignment: .leading) {
                  Text(customer.fullName)
                    .font(.headline)
                    .lineLimit(2)
                  
                  Text(verbatim: customer.email)
                    .font(.footnote)
                    .fontWeight(.light)
                    .lineLimit(2)
                }
                Spacer()
                NavigationLink {
                  LazyView(EditProfileView(
                    viewModel: .init(rootViewModel: rootViewModel)
                  ))
                } label: {
                  Image(systemName: "square.and.pencil")
                    .font(.system(size: 24))
                }
              }
              
              VStack(alignment: .leading) {
                Text("Contribution")
                  .font(.headline)
                
                RoundedRectangle(cornerRadius: 10)
                  .fill(.white.opacity(0.2))
                  .shadow(radius: 1)
                  .frame(height: 70)
                  .overlay {
                    HStack {
                      VStack {
                        Text("0")
                          .font(.title2)
                          .fontWeight(.semibold)
                        Text("Food Rescued")
                          .font(.subheadline)
                      }
                      
                      RoundedRectangle(cornerRadius: 2)
                        .fill(Color.secondary.opacity(0.2))
                        .frame(width: 1, height: 40)
                        .padding(.horizontal)
                      
                      VStack {
                        Text("0")
                          .font(.title2)
                          .fontWeight(.semibold)
                        Text("Food Shared")
                          .font(.subheadline)
                      }
                    }
                    .padding(.horizontal)
                  }
              }
              .padding(.top)
              
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            
            VStack(alignment: .leading, spacing: 25) {
              Text("More")
                .font(.headline)
                .bold()
              SettingsMoreItemView(
                imgSystemName: "banknote",
                title: "Wallet",
                subtitle: "Check your balance, top-up, and more",
                goToDestination: {
                  LazyView(WalletDetailsView(
                    viewModel: WalletDetailsViewModel(userId: customer.id)))
                }
              )
              SettingsMoreItemView(
                imgSystemName: "house",
                title: "Shipping Address",
                subtitle: "Manage your shipping address",
                goToDestination: {
                  LazyView(Text("Coming soon"))
                }
              )
              SettingsMoreItemView(
                imgSystemName: "archivebox",
                title: "Order History",
                subtitle: "See what you've ordered in the past",
                goToDestination: {
                  LazyView(Text("Coming soon"))
                }
              )
              
              RoundedRectangle(cornerRadius: 0)
                .fill(Color.secondary.opacity(0.2))
                .frame(
                  width: UIScreen.main.bounds.width,
                  height: 10
                )
                .position(x: UIScreen.main.bounds.width / 2.17)
                .padding(.top)
              
              Button(action: { showingSignOutDialog = true }) {
                HStack {
                  Image(systemName: "rectangle.portrait.and.arrow.right")
                    .rotation3DEffect(
                      .degrees(180),
                      axis: (x: 0, y:1, z: 0)
                    )
                  
                  VStack(alignment: .leading) {
                    Text("Sign Out")
                  }
                  .padding(.leading)
                }
                .foregroundColor(.black)
              }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            
          }
        }
        .background(Color.backgroundColor)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
//          let appearance = UINavigationBarAppearance()
//          appearance.configureWithTransparentBackground()
//          appearance.backgroundColor = UIColor(named: "BackgroundColor")
//          UINavigationBar.appearance().scrollEdgeAppearance = appearance
//          UINavigationBar.appearance().standardAppearance = appearance
//          UINavigationBar.appearance().tintColor = .black
          
//          NotificationCenter.default.post(name: .navBarChangeBackgroundToBackgroundColorNotification, object: nil)
          setNavigationBarColor(withStandardColor: .backgroundColor, andScrollEdgeColor: .backgroundColor)
          NotificationCenter.default.post(
            name: .tabBarShownNotification,
            object: nil)
          NotificationCenter.default.post(
            name: .tabBarChangeBackgroundToBackgroundColorNotification,
            object: nil)
        }
        
        .confirmationDialog(
          "Are you sure want to sign out?",
          isPresented: $showingSignOutDialog,
          titleVisibility: .visible
        ) {
          Button("Sign Out",
                 role: .destructive,
                 action: signOut)
          Button("Cancel", role: .cancel) {
            showingSignOutDialog = false
          }
        }
        
      } else {
        Color.backgroundColor.ignoresSafeArea()
      }
    }
  }
  
  private func signOut() {
    AuthenticationService.shared.signOut()
    rootViewModel.selectedTab = 0
  }
}

struct MyProfileView_Previews: PreviewProvider {
  static var previews: some View {
    MyProfileView()
  }
}

private extension MyProfileView {
  struct SettingsMoreItemView<Destination: View>: View {
    let imgSystemName: String
    let title: String
    let subtitle: String
    let goToDestination: () -> Destination
    
    var body: some View {
      NavigationLink(destination: goToDestination) {
        HStack(spacing: 25) {
          Image(systemName: imgSystemName)
            .foregroundColor(.black)
          VStack(alignment: .leading) {
            Text(title).foregroundColor(.black)
            Text(subtitle)
              .font(.caption)
              .foregroundColor(.secondary)
          }
        }
      }
    }
  }
}
