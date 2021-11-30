//
//  SignUpView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 16/11/21.
//

import SwiftUI
import PhotosUI

struct SignUpView: View {
  @StateObject private var viewModel: SignUpViewModel
  @ObservedObject private var keyboard = KeyboardResponder()
  
  @FocusState private var fullNameFieldFocused: Bool
  @FocusState private var emailFieldFocused: Bool
  @FocusState private var passwordFieldFocused: Bool
  
  @State private var showImagePicker = false
  @State private var showErrorSnackbar = false
  @State private var showSettingUpAccountSnackbar = false
  
  private var onReceiveCustomer: (Customer) -> Void
  
  init(viewModel: SignUpViewModel,
       onReceiveCustomer: @escaping (Customer) -> Void) {
    _viewModel = StateObject(wrappedValue: viewModel)
    self.onReceiveCustomer = onReceiveCustomer
  }
  
  var body: some View {
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
            if let image = viewModel.profileImage {
              image
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
            } else {
              Image(systemName: "person.circle.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, Color(uiColor: .lightGray).opacity(0.5))
                .font(.system(size: 100))
            }
            photoPickerButton
          }
          
          VStack(spacing: 25) {
            InputFieldContainer(
              isError: !(viewModel.fullNameValid ?? true),
              label: "Full Name"
            ) {
              TextField("Enter your name", text: $viewModel.fullName)
                .disableAutocorrection(true)
                .focused($fullNameFieldFocused)
                .onChange(
                  of: fullNameFieldFocused,
                  perform: viewModel.validateFullNameIfFocusIsLost
                )
            }
            
            InputFieldContainer(
              isError: !(viewModel.emailValid ?? true),
              label: "Email"
            ) {
              TextField("Enter your email address", text: $viewModel.email)
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
              SecureField("8 char long, 1 uppercase, 1 number", text: $viewModel.password)
                .disableAutocorrection(true)
                .focused($passwordFieldFocused)
                .onChange(
                  of: passwordFieldFocused,
                  perform: viewModel.validatePasswordIfFocusIsLost
                )
            }
          }
          .padding(.bottom, 50)
          
          Button(
            action: signUp,
            label: {
              RoundedRectangle(cornerRadius: 10)
                .fill(Color.accentColor)
                .frame(height: 48)
                .overlay {
                  Text("Sign up").foregroundColor(.white)
                }
            }
          )
            .disabled(viewModel.signUpButtonDisabled)
        }
        .frame(
          width: UIScreen.main.bounds.width * 0.8
        )
        .padding(20)
        .background(Color.backgroundColor)
        .cornerRadius(15)
        .padding(.vertical)
      }
      .padding(.bottom, keyboard.currentHeight)
      .animation(.easeOut, value: keyboard.currentHeight)
    }
    .sheet(isPresented: $showImagePicker) {
      PHPickerViewController.View(
        selectionLimit: 1,
        imageData: $viewModel.profileImageData
      )
    }
    .navigationTitle("Create Account")
    .edgesIgnoringSafeArea(.bottom)
    .onReceive(
      viewModel.$signedInCustomer.compactMap { $0 },
      perform: onReceiveCustomer
    )
    .onReceive(viewModel.$errorMessage.dropFirst()) { message in
      showErrorSnackbar.toggle()
    }
    .snackBar(
      isShowing: $showSettingUpAccountSnackbar,
      text: Text("Setting up your account...")
    )
    .snackBar(
      isShowing: $showErrorSnackbar,
      text: Text(viewModel.errorMessage),
      isError: true
    )
  }
  
  private var photoPickerButton: some View {
    let title = viewModel.profileImageData == nil
      ? "Add Profile Picture"
      : "Change Profile Picture"
    return Button(title) { showImagePicker.toggle() }
  }
  
  private func signUp() {
    showSettingUpAccountSnackbar.toggle()
    viewModel.signUp()
  }
}

struct SignUpView_Previews: PreviewProvider {
  static var previews: some View {
    SignUpView(viewModel: .init(), onReceiveCustomer: { _ in})
  }
}

extension SignUpViewModel {
  var profileImage: Image? {
    guard let profileImageData = profileImageData,
          let uiImage = UIImage(data: profileImageData) else {
      return nil
    }
    return Image(uiImage: uiImage)
  }
}
