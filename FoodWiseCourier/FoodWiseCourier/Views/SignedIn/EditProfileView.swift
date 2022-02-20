//
//  EditProfileView.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 02/12/21.
//

import SwiftUI
import PhotosUI
import SDWebImageSwiftUI

struct EditProfileView: View {
  @EnvironmentObject var mainViewModel: MainViewModel
  @Environment(\.dismiss) private var dismiss
  
  @StateObject private var viewModel: EditProfileViewModel
  @StateObject private var keyboard: KeyboardResponder
  
  @FocusState private var nameFieldFocused: Bool
  @FocusState private var brandFieldFocused: Bool
  @FocusState private var plateFieldFocused: Bool
  
  @State private var licenseNoText: String? = nil
  @State private var showImagePicker = false
  @State private var showLicenseView = false
  @State private var showErrorSnackbar = false
  @State private var showSavingChangesSnackbar = false
  
  private static var licenseViewModel: DrivingLicenseViewModel!
  
  init(viewModel: EditProfileViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
    _keyboard = StateObject(wrappedValue: KeyboardResponder())
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
              WebImage(url: mainViewModel.courier.profilePictureUrl)
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
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
            }
            Button("Change Profile Picture") { showImagePicker.toggle() }
          }
          
          VStack(spacing: 25) {
            InputFieldContainer(
              isError: !viewModel.nameValid,
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
              isError: !viewModel.bikeBrandValid,
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
              isError: !viewModel.bikePlateValid,
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
              isError: !viewModel.licenseValid,
              label: "Driving License"
            ) {
              TextField(
                "Set up your driving license",
                text: .constant(licenseNoText ?? mainViewModel.courier.license.licenseNo)
              )
              .disabled(true)
              .overlay(alignment: .trailing) {
                Image(systemName: "chevron.forward")
                  .foregroundColor(.accentColor)
              }
            }
            .onTapGesture {
              let licenseNo = viewModel.license.licenseNo
              if viewModel.license.imageData != nil {
                Self.licenseViewModel = .init(licenseNo: licenseNo)
              } else {
                Self.licenseViewModel = .init(
                  imageUrl: mainViewModel.courier.license.imageUrl,
                  licenseNo: licenseNo
                )
              }
              showLicenseView.toggle()
              
            }
          }
          .padding(.bottom, 50)
          
          Button(action: save) {
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
          }
          .disabled(viewModel.buttonDisabled)
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
    .onReceive(mainViewModel.$courier.compactMap { $0 }) { _ in
      dismiss()
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
    .fullScreenCover(isPresented: $showLicenseView) {
      if let licenseNoValid = Self.licenseViewModel.licenseNoValid,
         licenseNoValid {
        licenseNoText = Self.licenseViewModel.licenseNo
        viewModel.license = (Self.licenseViewModel.imageData, Self.licenseViewModel.licenseNo)
      } else {
        licenseNoText = ""
        viewModel.license = (Self.licenseViewModel.imageData, "")
      }
      viewModel.validateLicenseIfFocusIsLost(focus: false)
    } content: {
      LazyView(
        DrivingLicenseView(viewModel: Self.licenseViewModel)
      )
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
  
  private func save() {
    showSavingChangesSnackbar.toggle()
    viewModel.saveChanges()
  }
}

struct EditProfileView_Previews: PreviewProvider {
  static var previews: some View {
    EditProfileView(viewModel: .init(mainViewModel: .init()))
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
