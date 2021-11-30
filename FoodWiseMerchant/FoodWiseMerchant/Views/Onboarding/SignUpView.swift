//
//  RegisterMerchant.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 19/11/21.
//

import SwiftUI
import PhotosUI

struct RegisterMerchantView: View {
  @StateObject private var viewModel: SignUpViewModel
  @StateObject private var locationViewModel: SelectLocationViewModel
  @StateObject private var keyboard: KeyboardResponder
  
  @FocusState private var nameFieldFocused: Bool
  @FocusState private var storeTypeFieldFocused: Bool
  @FocusState private var emailFieldFocused: Bool
  @FocusState private var passwordFieldFocused: Bool
  
  @State private var showImagePicker = false
  @State private var showLocationPicker = false
  @State private var showErrorSnackbar = false
  @State private var showSettingUpAccountSnackbar = false
  
  @State private var addressText = ""

  private var onReceiveMerchant: (Merchant) -> Void
  
  init(viewModel: SignUpViewModel,
       locationViewModel: SelectLocationViewModel,
       onReceiveMerchant: @escaping (Merchant) -> Void
  ) {
    _viewModel = StateObject(wrappedValue: viewModel)
    _locationViewModel = StateObject(wrappedValue: locationViewModel)
    _keyboard = StateObject(wrappedValue: KeyboardResponder())
    self.onReceiveMerchant = onReceiveMerchant
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
                  Image("store-logo-placeholder")
                    .resizable()
                    .frame(width: 70, height: 70)
                }
            }
            photoPickerButton
          }
          
          VStack(spacing: 25) {
            InputFieldContainer(
              isError: !(viewModel.nameValid ?? true),
              label: "Name"
            ) {
              TextField("Merchant's name", text: $viewModel.name)
                .disableAutocorrection(true)
                .focused($nameFieldFocused)
                .onChange(
                  of: nameFieldFocused,
                  perform: viewModel.validateNameIfFocusIsLost
                )
            }
            
            InputFieldContainer(
              isError: !(viewModel.storeTypeValid ?? true),
              label: "Type"
            ) {
              TextField("Merchant's type (eg. Restaurant)", text: $viewModel.storeType)
                .disableAutocorrection(true)
                .focused($storeTypeFieldFocused)
                .onChange(
                  of: storeTypeFieldFocused,
                  perform: viewModel.validateStoreTypeIfFocusIsLost
                )
            }
            
            InputFieldContainer(
              isError: !(viewModel.addressValid ?? true),
              label: "Address"
            ) {
              TextField("Merchant's address and location", text: .constant(addressText))
                .disabled(true)
                .overlay(alignment: .trailing) {
                  Image(systemName: "chevron.forward")
                    .foregroundColor(.accentColor)
                }
                .onTapGesture { showLocationPicker.toggle() }
            }
            
            InputFieldContainer(
              isError: !(viewModel.emailValid ?? true),
              label: "Email"
            ) {
              TextField("Merchant's email", text: $viewModel.email)
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
          }.disabled(viewModel.signUpButtonDisabled)
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
      viewModel.$signedInMerchant.compactMap { $0 },
      perform: onReceiveMerchant
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
    .fullScreenCover(isPresented: $showLocationPicker, onDismiss: {
      if let coord = locationViewModel.coordinate {
        addressText = locationViewModel.geocodedLocation
        viewModel.address = (coord.latitude,
                             coord.longitude,
                             locationViewModel.addressDetails)
      } else {
        addressText = ""
        viewModel.address = nil
      }
      viewModel.validateAddressIfFocusIsLost(focus: false)
    }) {
      LazyView(SelectLocationView(viewModel: locationViewModel))
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
      ? "Add Merchant's Logo"
      : "Change Logo"
    return Button(title) { showImagePicker.toggle() }
  }
  
  private func signUp() {
    showSettingUpAccountSnackbar.toggle()
    viewModel.signUp()
  }
}

struct RegisterMerchantView_Previews: PreviewProvider {
  static var previews: some View {
    RegisterMerchantView(viewModel: .init(), locationViewModel: .init(), onReceiveMerchant: { _ in})
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
  
  var coordinate: CLLocationCoordinate2D? {
    if let lat = address?.lat, let long = address?.long {
      return .init(latitude: lat, longitude: long)
    }
    return nil
  }
}
