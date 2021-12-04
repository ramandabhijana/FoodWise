//
//  EditProfileView.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 01/12/21.
//

import SwiftUI
import PhotosUI
import SDWebImageSwiftUI

struct EditProfileView: View {
  @EnvironmentObject var mainViewModel: MainViewModel
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel: EditProfileViewModel
  @StateObject private var keyboard: KeyboardResponder
  private static var locationViewModel: SelectLocationViewModel!
  
  @FocusState private var nameFieldFocused: Bool
  @FocusState private var storeTypeFieldFocused: Bool
  @FocusState private var emailFieldFocused: Bool
  @FocusState private var passwordFieldFocused: Bool
  
  @State private var showImagePicker = false
  @State private var showLocationPicker = false
  @State private var showErrorSnackbar = false
  @State private var showSavingChangesSnackbar = false
  @State private var addressText: String? = nil
  @Binding var showingSelf: Bool
  
  init(showingSelf: Binding<Bool>, viewModel: EditProfileViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
    _keyboard = StateObject(wrappedValue: KeyboardResponder())
    _showingSelf = showingSelf
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
            if let image = viewModel.profileImageData?.asImage {
              image
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
            } else {
              WebImage(url: mainViewModel.merchant.logoUrl)
                .resizable()
                .placeholder {
                  Circle()
                    .fill(Color(uiColor: .lightGray).opacity(0.6))
                    .frame(width: 100, height: 100)
                    .overlay {
                      ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .tint(.white)
                    }
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
            }
            photoPickerButton
          }
          
          VStack(spacing: 25) {
            InputFieldContainer(
              isError: !viewModel.nameValid,
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
              isError: !viewModel.storeTypeValid,
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
              isError: !viewModel.addressValid,
              label: "Address"
            ) {
              TextField(
                "Merchant's address and location",
                text: .constant(addressText ?? viewModel.address!.location.geocodedLocation)
              )
              .disabled(true)
              .overlay(alignment: .trailing) {
                Image(systemName: "chevron.forward")
                  .foregroundColor(.accentColor)
              }
              .onTapGesture {
                Self.locationViewModel = .init(
                  coordinate: viewModel.address?.location.coordinate,
                  addressDetails: viewModel.address?.details
                )
                showLocationPicker.toggle()
              }
            }
            
          }
          .padding(.bottom, 50)
          Button(action: viewModel.saveChanges) {
//          Button(action: { presentationMode.wrappedValue.dismiss() }) {
            RoundedRectangle(cornerRadius: 10)
              .fill(Color.accentColor)
              .frame(height: 48)
              .overlay {
                if viewModel.savingUpdate {
                  ProgressView().tint(.white)
                } else {
                  Text("Save Changes").foregroundColor(.white)
                }
              }
          }.disabled(viewModel.buttonDisabled)
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
    .navigationTitle("Edit Profile")
    .edgesIgnoringSafeArea(.bottom)
    .onReceive(mainViewModel.$merchant.compactMap { $0 }) { _ in
      showingSelf = false
    }
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
      if let coord = Self.locationViewModel.coordinate {
        addressText = Self.locationViewModel.geocodedLocation
        let merchantLocation = MerchantLocation(
          lat: coord.latitude as Double,
          long: coord.longitude as Double,
          geocodedLocation: Self.locationViewModel.geocodedLocation
        )
        viewModel.address = (merchantLocation,
                             Self.locationViewModel.addressDetails)
      } else {
        addressText = ""
        viewModel.address = nil
      }
      viewModel.validateAddressIfFocusIsLost(focus: false)
    }) {
      LazyView(SelectLocationView(viewModel: Self.locationViewModel))
    }
    .snackBar(
      isShowing: $showSavingChangesSnackbar,
      text: Text("Saving changes...")
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
  
  private func save() {
    showSavingChangesSnackbar = true
    
  }
}

struct EditProfileView_Previews: PreviewProvider {
  static var previews: some View {
    EditProfileView(
      showingSelf: .constant(true),
      viewModel: .init(mainViewModel: .init())
    )
  }
}

extension Data {
  var asImage: Image? {
    guard let uiImage = UIImage(data: self) else {
      return nil
    }
    return Image(uiImage: uiImage)
  }
}


