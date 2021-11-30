//
//  OnboardingView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 19/11/21.
//

import SwiftUI

struct SignInView: View {
  @StateObject private var viewModel: SignInViewModel
  
  @FocusState private var emailFieldFocused: Bool
  @FocusState private var passwordFieldFocused: Bool
  
  @State private var showErrorSnackbar = false
  @State private var showSigningInSnackbar = false
  
  private var onReceiveCourier: (Courier) -> Void
  
  init(viewModel: SignInViewModel,
       onReceiveCourier: @escaping (Courier) -> Void) {
    _viewModel = StateObject(wrappedValue: viewModel)
    self.onReceiveCourier = onReceiveCourier
  }
  
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
      .onReceive(
        viewModel.$signedInCourier.compactMap { $0 },
        perform: onReceiveCourier
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
  }
}

struct OnboardingView_Previews: PreviewProvider {
  static var previews: some View {
    SignInView(viewModel: .init(), onReceiveCourier: { _ in})
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
                    ProgressView().tint(.white)
                  } else {
                    Text("Sign in").foregroundColor(.white)
                  }
                }
            }
            .disabled(viewModel.signInButtonDisabled)
            
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
      LazyView(
        SignUpView(
          viewModel: .init(),
          licenseViewModel: .init(),
          onReceiveCourier: onReceiveCourier
        )
      )
    }
  }
  
  private func signIn() {
    showSigningInSnackbar.toggle()
    viewModel.signIn()
  }
}
