//
//  SignInView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 30/10/21.
//

import SwiftUI

public struct SignInView: View {
  @StateObject private var viewModel: SignInViewModel
  
  @FocusState private var emailFieldFocused: Bool
  @FocusState private var passwordFieldFocused: Bool
  
  @State private var showErrorSnackbar = false
  @State private var showSigningInSnackbar = false
  
  private var onReceiveCustomer: (Customer) -> Void
  
  init(viewModel: SignInViewModel,
       onReceiveCustomer: @escaping (Customer) -> Void) {
    _viewModel = StateObject(wrappedValue: viewModel)
    self.onReceiveCustomer = onReceiveCustomer
  }
  
  public var body: some View {
    ZStack {
      Color.primaryColor
        .overlay(alignment: .bottom) {
          Image.footerFoods
            .resizable()
            .scaledToFit()
        }
      
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
                isError: !(viewModel.emailValid ?? true),
                label: "Email"
              ) {
                TextField(
                  "Enter your email address",
                  text: $viewModel.email
                )
                .keyboardType(.emailAddress)
                .disableAutocorrection(true)
                .focused($emailFieldFocused)
                .onChange(
                  of: emailFieldFocused,
                  perform: viewModel.validateEmailIfFocusIsLost
                )
              }
              
              InputFieldContainer(
                isError: !(viewModel.passwordValid ?? true),
                label: "Password"
              ) {
                SecureField(
                  "Enter your password",
                  text: $viewModel.password
                )
                .disableAutocorrection(true)
                .focused($passwordFieldFocused)
                .onChange(
                  of: passwordFieldFocused,
                  perform: viewModel.validatePasswordIfFocusIsLost
                )
              }
              
              Spacer()
              
              Button(action: signIn) {
                RoundedRectangle(cornerRadius: 10)
                  .fill(Color.accentColor)
                  .frame(height: 48)
                  .overlay {
                    if viewModel.loadingUser {
                      ProgressView()
                        .tint(.white)
                    } else {
                      Text("Sign in")
                        .foregroundColor(.white)
                    }
                  }
              }
              .disabled(viewModel.signInButtonDisabled)
                
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
    .ignoresSafeArea()
    .navigationTitle("Sign In")
    .onReceive(
      viewModel.$signedInCustomer.compactMap { $0 },
      perform: { customer in
        onReceiveCustomer(customer)
      }
    )
    .onReceive(viewModel.$errorMessage.dropFirst()) { message in
      showErrorSnackbar.toggle()
    }
    .snackBar(
      isShowing: $showSigningInSnackbar,
      text: Text("Signing in...")
    )
    .snackBar(
      isShowing: $showErrorSnackbar,
      text: Text(viewModel.errorMessage),
      isError: true
    )
  }
  
  private func signIn() {
    showSigningInSnackbar.toggle()
    viewModel.signIn()
  }
}

struct SignInView_Previews: PreviewProvider {
  static var previews: some View {
    SignInView(viewModel: .init(), onReceiveCustomer: { _ in})
  }
}
