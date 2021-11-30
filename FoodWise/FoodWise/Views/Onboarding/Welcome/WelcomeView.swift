//
//  WelcomeView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 30/10/21.
//

import SwiftUI

struct WelcomeView: View {
  @Environment(\.presentationMode) var presentationMode
  @EnvironmentObject var rootViewModel: RootViewModel
  private var onReceiveCustomer: (Customer) -> Void
  
  init(onReceiveCustomer: @escaping (Customer) -> Void) {
    self.onReceiveCustomer = onReceiveCustomer
  }
  
  var body: some View {
    NavigationView {
      ZStack {
        backgroundGradient
        VStack {
          heroView
            .padding(.bottom, 60)
          Spacer()
          authenticationView
        }
        .frame(
          width: UIScreen.main.bounds.width * 0.86,
          height: UIScreen.main.bounds.height * 0.86
        )
      }
      .navigationBarTitleDisplayMode(.inline)
      .ignoresSafeArea()
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Skip") {
            if rootViewModel.selectedTab == 3 {
              rootViewModel.selectedTab = 0
            }
            presentationMode.wrappedValue.dismiss()
          }
        }
      }
    }
  }
}

struct WelcomeView_Previews: PreviewProvider {
  static var previews: some View {
    WelcomeView(onReceiveCustomer: { _ in })
    
  }
}

// MARK: - Components
private extension WelcomeView {
  var heroView: some View {
    let imageSize = UIScreen.main.bounds.width * 0.4
    return VStack {
      Image.appLogo
        .resizable()
        .frame(
          width: imageSize,
          height: imageSize
        )
      Text("Food Wise")
        .font(.system(size: 48))
        .fontWeight(.thin)
      Text("Be wise don't waste")
        .font(.subheadline)
    }
    .foregroundColor(.secondary)
  }
  
  var backgroundGradient: some View {
    let gradient = Gradient(
      stops: [
        .init(color: .primaryColor, location: 0.1),
        .init(color: .backgroundColor, location: 0.8)
      ]
    )
    return LinearGradient(
      gradient: gradient,
      startPoint: .bottom,
      endPoint: .top
    )
  }
  
  var authenticationView: some View {
    RoundedRectangle(cornerRadius: 20)
      .fill(Color.backgroundColor)
      .frame(
        height: UIScreen.main.bounds.height * 0.3
      )
      .overlay {
        GeometryReader { proxy in
          VStack(spacing: 50) {
            makeButtonStack(parentSize: proxy.size)
            registerOptionView
          }
          .frame(
            width: proxy.size.width * 0.8
          )
          .position(
            x: proxy.size.width / 2,
            y: proxy.size.height / 2
          )
        }
      }
  }
  
  var registerOptionView: some View {
    HStack {
      Text("New Here?").fontWeight(.light)
//      NavigationLink("Create Account") {
//        SignUpView(viewModel: .init(),
//                   onReceiveCustomer: onReceiveCustomer)
//      }
    }
  }
  
  func makeButtonStack(parentSize size: CGSize) -> some View {
    VStack(spacing: 16) {
      Button(action: { }) {
        SignInButtonLabel(
          image: .googleLogo.resizable(),
          title: Text("Sign in with Google")
        )
      }
      .frame(height: size.height * 0.18)
      
      NavigationLink {
        SignInView(viewModel: .init(),
                   onReceiveCustomer: onReceiveCustomer)
      } label: {
        SignInButtonLabel(
          image: Image(systemName: "envelope.fill"),
          title: Text("Sign in with Email")
        )
          .frame(height: size.height * 0.18)
      }
    }
    .foregroundColor(.black)
  }
  
  struct SignInButtonLabel: View {
    var image: Image
    var title: Text
    
    var body: some View {
      RoundedRectangle(cornerRadius: 10)
        .fill(.white)
        .shadow(radius: 1)
        .overlay(alignment: .leading) {
          HStack(spacing: 20) {
            image
              .frame(width: 18, height: 18)
            title
          }
          .padding(.horizontal)
        }
    }
  }
}
