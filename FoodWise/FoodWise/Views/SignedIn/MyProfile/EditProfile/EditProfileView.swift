//
//  EditProfileView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 03/12/21.
//

import SwiftUI
import PhotosUI
import SDWebImageSwiftUI

struct EditProfileView: View {
  @EnvironmentObject var rootViewModel: RootViewModel
  @Environment(\.dismiss) private var dismiss
  
  @StateObject private var viewModel: EditProfileViewModel
  @StateObject private var keyboard: KeyboardResponder
  
  @FocusState private var fullNameFieldFocused: Bool
  
  @State private var showImagePicker = false
  @State private var showErrorSnackbar = false
  @State private var showSavingChangesSnackbar = false
  
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
            Group {
              if let image = viewModel.profileImageData?.asImage {
                image.resizable()
              } else {
                WebImage(url: rootViewModel.customer?.profileImageUrl)
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
              }
            }
            .scaledToFill()
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            
            Button("Change Profile Picture") { showImagePicker.toggle() }
          }
          
          VStack(spacing: 50) {
            InputFieldContainer(
              isError: !viewModel.nameValid,
              label: "Full Name"
            ) {
              TextField("Enter your name", text: $viewModel.fullName)
                .disableAutocorrection(true)
                .focused($fullNameFieldFocused)
                .onChange(
                  of: fullNameFieldFocused,
                  perform: viewModel.validateNameIfFocusIsLost
                )
            }
            
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
            }.disabled(viewModel.buttonDisabled)
          }
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
    .onAppear {
      NotificationCenter.default.post(
        name: .tabBarHiddenNotification,
        object: nil)
    }
    .onDisappear {
      NotificationCenter.default.post(
        name: .tabBarShownNotification,
        object: nil)
    }
    .sheet(isPresented: $showImagePicker) {
      PHPickerViewController.View(
        selectionLimit: 1,
        imageData: $viewModel.profileImageData
      )
    }
    .navigationTitle("Edit Profile")
    .edgesIgnoringSafeArea(.bottom)
    .onReceive(rootViewModel.$customer.compactMap { $0 }) { _ in
      dismiss()
    }
    .onReceive(viewModel.$errorMessage.dropFirst()) { message in
      showErrorSnackbar.toggle()
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
    EditProfileView(viewModel: .init(rootViewModel: .init()))
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
