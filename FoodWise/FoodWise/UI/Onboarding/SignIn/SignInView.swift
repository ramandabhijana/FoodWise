//
//  SignInView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 30/10/21.
//

import SwiftUI

public struct SignInView: View {
  
  
  public var body: some View {
    NavigationView {
      ZStack {
        Color.primaryColor
        
        RoundedRectangle(cornerRadius: 20)
          .fill(Color.backgroundColor)
          .frame(
            width: UIScreen.main.bounds.width * 0.9,
            height: UIScreen.main.bounds.height * 0.5
          )
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
                height: proxy.size.height * 0.7
              )
              .position(
                x: proxy.size.width / 2,
                y: proxy.size.height / 2
              )
            }
          }
      }
      .navigationTitle("Sign In")
      .overlay(alignment: .bottom) {
        Image.footerFoods
          .resizable()
          .scaledToFit()
      }
      .ignoresSafeArea()
    }
  }
}

struct SignInView_Previews: PreviewProvider {
  static var previews: some View {
    SignInView()
  }
}
