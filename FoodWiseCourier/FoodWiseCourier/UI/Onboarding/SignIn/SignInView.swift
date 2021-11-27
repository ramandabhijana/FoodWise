//
//  OnboardingView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 19/11/21.
//

import SwiftUI

struct SignInView: View {
  var body: some View {
    NavigationView {
      ZStack {
        backgroundGradient
        VStack {
          logoView.padding(.bottom, 60)
          signInView
          Spacer()
          registerOptionView
        }
        .frame(
          width: UIScreen.main.bounds.width * 0.86,
          height: UIScreen.main.bounds.height * 0.86
        )
      }
      .navigationBarHidden(true)
      .ignoresSafeArea()
    }
    
  }
}

struct OnboardingView_Previews: PreviewProvider {
  static var previews: some View {
    SignInView()
  }
}

// MARK: - Components
private extension SignInView {
  var logoView: some View {
    let imageSize = UIScreen.main.bounds.width * 0.35
    return Image.appLogo
      .resizable()
      .frame(
        width: imageSize,
        height: imageSize
      )
  }
  
  var backgroundGradient: some View {
    let gradient = Gradient(
      stops: [
        .init(color: .primaryColor, location: 0.3),
        .init(color: .backgroundColor, location: 0.95)
      ]
    )
    return LinearGradient(
      gradient: gradient,
      startPoint: .bottom,
      endPoint: .top
    )
  }
  
  var signInView: some View {
    RoundedRectangle(cornerRadius: 20)
      .fill(Color.backgroundColor)
      .frame(
        height: UIScreen.main.bounds.height * 0.45
      )
      .shadow(radius: 2)
      .overlay {
        GeometryReader { proxy in
          VStack(spacing: 20) {
            InputFieldContainer(
              isError: .constant(false),
              label: "Email"
            ) {
              TextField("Enter your email address", text: .constant(""))
                .keyboardType(.emailAddress)
                .disableAutocorrection(true)
            }
            
            InputFieldContainer(
              isError: .constant(false),
              label: "Password"
            ) {
              SecureField("Enter your password", text: .constant(""))
            }
            
            Spacer()
            
            RoundedRectangle(cornerRadius: 10)
              .fill(Color.accentColor)
              .frame(height: 48)
              .overlay {
                Button(
                  action: { },
                  label: {
                    Text("Sign in")
                      .foregroundColor(.white)
                  })
              }
            
          }
          .frame(
            width: proxy.size.width * 0.85,
            height: proxy.size.height * 0.75
          )
          .position(
            x: proxy.size.width / 2,
            y: proxy.size.height / 2
          )
        }
      }
  }
  
  var registerOptionView: some View {
    NavigationLink("I need a new account") {
      Text("dklm")
    }
  }
  
  struct SignInButton: View {
    var action: () -> ()
    var image: Image
    var title: Text
    
    var body: some View {
      Button(
        action: action,
        label: {
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
      )
    }
  }
}
