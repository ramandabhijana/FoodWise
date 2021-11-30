//
//  SignUpView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 19/11/21.
//

import SwiftUI
import PhotosUI

struct SignUpView: View {
  @StateObject private var viewModel: SignUpViewModel
  @StateObject private var licenseViewModel: DrivingLicenseViewModel
  @StateObject private var keyboard: KeyboardResponder
  
  @FocusState private var nameFieldFocused: Bool
  @FocusState private var brandFieldFocused: Bool
  @FocusState private var plateFieldFocused: Bool
  @FocusState private var emailFieldFocused: Bool
  @FocusState private var passwordFieldFocused: Bool
  
  @State private var licenseNoText = ""
  @State private var showImagePicker = false
  @State private var showLicenseView = false
  @State private var showErrorSnackbar = false
  @State private var showSettingUpAccountSnackbar = false
  
  private var onReceiveCourier: (Courier) -> Void
  
  init(
    viewModel: SignUpViewModel,
    licenseViewModel: DrivingLicenseViewModel,
    onReceiveCourier: @escaping (Courier) -> Void
  ) {
    _viewModel = StateObject(wrappedValue: viewModel)
    _licenseViewModel = StateObject(wrappedValue: licenseViewModel)
    _keyboard = StateObject(wrappedValue: KeyboardResponder())
    self.onReceiveCourier = onReceiveCourier
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
              Circle()
                .fill(Color(uiColor: .lightGray).opacity(0.6))
                .frame(width: 100, height: 100)
                .overlay {
                  Image(systemName: "person.circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, Color(uiColor: .lightGray).opacity(0.5))
                    .font(.system(size: 100))
                }
            }
            photoPickerButton
          }
          
          VStack(spacing: 25) {
            InputFieldContainer(
              isError: !(viewModel.nameValid ?? true),
              label: "Full Name"
            ) {
              TextField("First name and Last name", text: $viewModel.fullName)
                .disableAutocorrection(true)
                .focused($nameFieldFocused)
                .onChange(
                  of: nameFieldFocused,
                  perform: viewModel.validateNameIfFocusIsLost
                )
            }
            
            InputFieldContainer(
              isError: !(viewModel.bikeBrandValid ?? true),
              label: "Bike Brand"
            ) {
              TextField("eg. Nmax, PCX, Vario", text: $viewModel.bikeBrand)
                .disableAutocorrection(true)
                .focused($brandFieldFocused)
                .onChange(
                  of: brandFieldFocused,
                  perform: viewModel.validateBikeBrandIfFocusIsLost
                )
            }
            
            InputFieldContainer(
              isError: !(viewModel.bikePlateValid ?? true),
              label: "Bike Plate"
            ) {
              TextField("eg. DK 4131 HD", text: $viewModel.bikePlate)
                .disableAutocorrection(true)
                .focused($plateFieldFocused)
                .onChange(
                  of: plateFieldFocused,
                  perform: viewModel.validateBikePlateIfFocusIsLost
                )
            }
            
            InputFieldContainer(
              isError: !(viewModel.licenseValid ?? true),
              label: "Driving License"
            ) {
              TextField("Set up your driving license", text: .constant(licenseNoText))
                .disabled(true)
                .overlay(alignment: .trailing) {
                  Image(systemName: "chevron.forward")
                    .foregroundColor(.accentColor)
                }
            }
            .onTapGesture { showLicenseView.toggle() }
            
            InputFieldContainer(
              isError: !(viewModel.emailValid ?? true),
              label: "Email"
            ) {
              TextField("Enter your email", text: $viewModel.email)
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
          
          Button(action: signUp) {
            RoundedRectangle(cornerRadius: 10)
              .fill(Color.accentColor)
              .frame(height: 48)
              .overlay {
                if viewModel.loadingUser {
                  ProgressView().tint(.white)
                } else {
                  Text("Sign up").foregroundColor(.white)
                }
              }
          }
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
    .navigationTitle("Create Account")
    .edgesIgnoringSafeArea(.bottom)
    .onReceive(
      viewModel.$signedInCourier.compactMap { $0 },
      perform: onReceiveCourier
    )
    .onReceive(viewModel.$errorMessage.dropFirst()) { _ in
      showErrorSnackbar.toggle()
    }
    .sheet(isPresented: $showImagePicker) {
      PHPickerViewController.View(
        selectionLimit: 1,
        imageData: $viewModel.profileImageData
      )
    }
    .fullScreenCover(isPresented: $showLicenseView) {
      if let imageData = licenseViewModel.imageData,
         let licenseNoValid = licenseViewModel.licenseNoValid,
         licenseNoValid {
        licenseNoText = licenseViewModel.licenseNo
        viewModel.license = (imageData, licenseViewModel.licenseNo)
      } else {
        licenseNoText = ""
        viewModel.license = nil
      }
      viewModel.validateLicenseIfFocusIsLost(focus: false)
    } content: {
      DrivingLicenseView(viewModel: licenseViewModel)
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

struct RegisterMerchantView_Previews: PreviewProvider {
  static var previews: some View {
    SignUpView(viewModel: .init(), licenseViewModel: .init(), onReceiveCourier: { _ in})
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
