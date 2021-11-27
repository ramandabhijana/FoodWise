//
//  SignUpView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 16/11/21.
//

import SwiftUI

struct SignUpView: View {
  var body: some View {
    NavigationView {
      ZStack {
        Color.primaryColor
          .edgesIgnoringSafeArea(.top)
          .overlay(alignment: .bottom) {
            Image.footerFoods
              .resizable()
              .scaledToFit()
          }
        
        ScrollView(showsIndicators: false) {
            VStack(spacing: 50) {
              VStack {
                Image(systemName: "person.circle.fill")
                  .symbolRenderingMode(.palette)
                  .foregroundStyle(.white, Color(uiColor: .lightGray))
                  .font(.system(size: 100))
//                Image("tgtg")
//                  .resizable()
//                  .scaledToFill()
//                  .frame(width: 100, height: 100)
//                  .clipShape(Circle())
                Button("Add Profile Picture") { }
              }
              
              
              
              VStack(spacing: 25) {
                
                InputFieldContainer(
                  isError: .constant(false),
                  label: "Full Name"
                ) {
                  TextField("Enter your name", text: .constant(""))
                    .disableAutocorrection(true)
                }
                
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
                    
                    .disableAutocorrection(true)
                }
              }
              .padding(.bottom, 50)
              
              Button(
                action: {
                  
                },
                label: {
                  RoundedRectangle(cornerRadius: 10)
                    .fill(Color.accentColor)
                    .frame(height: 48)
                    .overlay {
                      Text("Sign up")
                        .foregroundColor(.white)
                    }
                }
              )
                .disabled(true)
              
              
            }
            .frame(
              width: UIScreen.main.bounds.width * 0.8
            )
            .padding(20)
            .background(Color.backgroundColor)
            .cornerRadius(15)
            .padding(.vertical)
          }
        
      }
      
      .navigationTitle("Create Account")
      .edgesIgnoringSafeArea(.bottom)
    }
  }
}

struct SignUpView_Previews: PreviewProvider {
  static var previews: some View {
    SignUpView()
  }
}
