//
//  DonateFoodView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 13/03/22.
//

import SwiftUI
import PhotosUI

struct DonateFoodView: View {
  @EnvironmentObject private var rootViewModel: RootViewModel
  @StateObject private var viewModel: DonateFoodViewModel
  @StateObject private var locationViewModel: SelectLocationViewModel
  @FocusState private var noteFieldFocused: Bool
  @FocusState private var nameFieldFocused: Bool
  @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
  
  @Environment(\.presentationMode) var presentationMode
  
  init(viewModel: DonateFoodViewModel,
       locationViewModel: SelectLocationViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
    _locationViewModel = StateObject(wrappedValue: locationViewModel)
  }
  
  var body: some View {
    NavigationView {
      ScrollView(showsIndicators: false) {
        VStack(spacing: 25) {
          InputFieldContainer(
            isError: !(viewModel.isImageDataValid ?? true),
            label: "Photo",
            semiBoldLabel: false,
            fieldHeight: UIScreen.main.bounds.height * 0.25
          ) {
            ZStack {
              RoundedRectangle(cornerRadius: 8)
                .fill(Color.secondary.opacity(0.2))
                .overlay {
                  if let image = viewModel.imageData?.asImage {
                    image
                      .resizable()
                      .scaledToFit()
                      .overlay {
                        Button(action: { viewModel.showingCameraLibraryDialog = true }) {
                          ZStack {
                            Color.black.opacity(0.2)
                            VStack(spacing: 10) {
                              Image(systemName: "arrow.clockwise")
                                .font(.title3.bold())
                              Text("Reselect")
                                .fontWeight(.heavy)
                            }
                            .foregroundColor(.white)
                            .shadow(radius: 7)
                          }
                        }
                      }
                  } else {
                    Button(action: { viewModel.showingCameraLibraryDialog = true }) {
                      VStack(spacing: 10) {
                        Image(systemName: "photo")
                          .font(.system(size: 70))
                          .overlay(alignment: .topTrailing) {
                            Image(systemName: "plus")
                              .foregroundColor(.white)
                              .padding(3)
                              .background(Color.accentColor)
                              .clipShape(Circle())
                          }
                        Text("Take a picture or Select from library")
                      }
                      .foregroundColor(.secondary)
                    }
                  }
                }
            }
            
          }
          
          InputFieldContainer(
            isError: false,
            label: "Appropriate for",
            semiBoldLabel: false
          ) {
            TextField(
              "Edible, Compostable, or Animal feed",
              text: .constant(viewModel.selectedKind?.appropriateFor ?? "")
            )
              .disabled(true)
              .overlay(alignment: .trailing) {
                Menu {
                  ForEach(SharedFoodKind.allCases.dropFirst(), id: \.rawValue) { kind in
                    Button(action: { viewModel.selectedKind = kind }) {
                      Label(kind.appropriateFor,
                            systemImage: viewModel.selectedKind == kind ? "checkmark" : "")
                    }
                  }
                } label: {
                  Text("\(Image(systemName: "chevron.down.circle"))")
                    .fontWeight(.bold)
                }
              }
          }
          
          InputFieldContainer(
            isError: !(viewModel.isNameValid ?? true),
            label: "Name",
            semiBoldLabel: false
          ) {
            TextField(
              "Name of the food",
              text: $viewModel.foodName
            )
              .disableAutocorrection(true)
              .focused($nameFieldFocused)
              .onChange(of: nameFieldFocused) { focused in
                if !focused {
                  DispatchQueue.main.async {
                    viewModel.validateNameField()
                    setNavigationBarColor(
                      withStandardColor: .primaryColor,
                      andScrollEdgeColor: .primaryColor)
                    
                    NotificationCenter.default.post(name: .tabBarChangeBackgroundToSecondaryColorNotification, object: nil)
                  }
                }
                //                setNavigationBarColor(
                //                  withStandardColor: .primaryColor,
                //                  andScrollEdgeColor: .primaryColor)
              }
          }
          
          InputFieldContainer(
            isError: !(viewModel.isLocationValid ?? true),
            label: "Pick up Location",
            semiBoldLabel: false
          ) {
            TextField(
              "Select location on map",
              text: .constant(viewModel.address?.geocodedLocation ?? "")
            )
              .disabled(true)
              .overlay(alignment: .trailing) {
                Button("\(Image(systemName: "chevron.right.circle"))") {
                  if locationViewModel.region == nil {
                    locationViewModel.fetchUserLocation()
                  }
                  viewModel.showingLocationPicker = true
                }
                .font(.body.bold())
              }
          }
          
          InputFieldContainer(
            isError: false,
            label: "Note (Optional)",
            semiBoldLabel: false,
            fieldHeight: 150
          ) {
            TextEditor(text: $viewModel.note)
              .disableAutocorrection(true)
              .focused($noteFieldFocused)
          }
          
          Button(action: submitDonation) {
            RoundedRectangle(cornerRadius: 10)
              .fill(Color.accentColor)
              .frame(height: 44)
              .overlay {
                if !viewModel.isSubmittingDonation {
                  Text("Submit")
                    .foregroundColor(.white)
                } else {
                  ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.black)
                }
              }
          }
          .disabled(viewModel.buttonDisabled)
          .padding(.top)
        }
        .padding()
      }
      .background(Color.backgroundColor)
      .navigationTitle("Donate Food")
      .navigationBarTitleDisplayMode(.inline)
      .onAppear {
        setNavigationBarColor(
          withStandardColor: .primaryColor,
          andScrollEdgeColor: .primaryColor)
      }
      .onDisappear {
        setNavigationBarColor(withStandardColor: .backgroundColor, andScrollEdgeColor: .backgroundColor)
      }
      .overlay(alignment: .bottom) {
        if noteFieldFocused {
          HStack {
            Spacer()
            Button("Done") { noteFieldFocused = false }
          }
          .padding()
          .background(.thinMaterial)
        }
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("\(Image(systemName: "xmark"))") {
            presentationMode.wrappedValue.dismiss()
          }
          .foregroundColor(.init(uiColor: .darkGray))
        }
      }
      .confirmationDialog(
        "Select the source",
        isPresented: $viewModel.showingCameraLibraryDialog,
        titleVisibility: .hidden,
        actions: {
          Button("Camera") {
            sourceType = .camera
            viewModel.showingCameraLibraryDialog = false
            viewModel.showingImagePicker = true
          }
          Button("Library") {
            sourceType = .photoLibrary
            viewModel.showingCameraLibraryDialog = false
            viewModel.showingImagePicker = true
          }
        }
      )
      .sheet(
        isPresented: $viewModel.showingImagePicker,
        onDismiss: {
          
        }) {
          ImagePickerView(
            selectedImageData: $viewModel.imageData,
            sourceType: sourceType)
        }
        .fullScreenCover(
          isPresented: $viewModel.showingLocationPicker,
          onDismiss: {
            if let coordinate = locationViewModel.coordinate {
              viewModel.address = Address(
                location: coordinate,
                geocodedLocation: locationViewModel.geocodedLocation,
                details: locationViewModel.addressDetails)
            } else {
              viewModel.address = nil
            }
          },
          content: {
            LazyView(SelectLocationView(viewModel: locationViewModel))
            //          .onDisappear {
            //            NotificationCenter.default.post(name: .tabBarHiddenNotification, object: nil)
            //          }
          }
        )
        .snackBar(
          isShowing: $viewModel.showingSubmitSnackbar,
          text: Text("Submitting donation...")
        )
        .snackBar(
          isShowing: $viewModel.showingErrorSnackbar,
          text: Text("Something went wrong"),
          isError: true
        )
    }
    
    
  }
  
  private func submitDonation() {
    guard let customer = rootViewModel.customer else { return }
    viewModel.submitDonation(donor: customer)
  }
}
