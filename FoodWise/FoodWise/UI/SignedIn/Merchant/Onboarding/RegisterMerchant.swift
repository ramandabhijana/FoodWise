//
//  RegisterMerchant.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 19/11/21.
//

import SwiftUI

struct RegisterMerchantView: View {
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
                Circle()
                  .fill(Color(uiColor: .lightGray).opacity(0.6))
                  .frame(width: 100, height: 100)
                  .overlay {
                    Image("store-logo-placeholder")
                      .resizable()
                      .frame(width: 70, height: 70)
                  }
                Button("Add Your Logo") { }
              }
              
              VStack(spacing: 25) {
                
                InputFieldContainer(
                  isError: .constant(false),
                  label: "Name"
                ) {
                  TextField("Merchant's name", text: .constant(""))
                    .disableAutocorrection(true)
                }
                
                InputFieldContainer(
                  isError: .constant(false),
                  label: "Type"
                ) {
                  TextField("Merchant's type (eg. Restaurant)", text: .constant(""))
                    .disableAutocorrection(true)
                }
                
                
                InputFieldContainer(
                  isError: .constant(false),
                  label: "Address"
                ) {
                  TextField("Merchant's address and location", text: .constant(""))
                    .disabled(true)
                    .overlay(alignment: .trailing) {
                      Image(systemName: "chevron.forward")
                        .foregroundColor(.accentColor)
                    }
                    .onTapGesture {
                      
                    }
                }
                
                InputFieldContainer(
                  isError: .constant(false),
                  label: "Email"
                ) {
                  TextField("Merchant's email", text: .constant(""))
                    .keyboardType(.emailAddress)
                    .disableAutocorrection(true)
                }
                
                InputFieldContainer(
                  isError: .constant(false),
                  label: "Password"
                ) {
                  SecureField("Must be 6 chars long, include number", text: .constant(""))
                    
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
                      Button(
                        action: { },
                        label: {
                          Text("Sign up")
                            .foregroundColor(.white)
                        })
                    }
                })
              
              
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

struct RegisterMerchantView_Previews: PreviewProvider {
  static var previews: some View {
    RegisterMerchantView()
  }
}
