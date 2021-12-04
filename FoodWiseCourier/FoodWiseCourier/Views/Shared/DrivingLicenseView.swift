//
//  DrivingLicenseView.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 27/11/21.
//

import SwiftUI
import VisionKit
import SDWebImageSwiftUI

struct DrivingLicenseView: View {
  @StateObject private var viewModel: DrivingLicenseViewModel
  @Environment(\.presentationMode) var presentationMode
  
  @FocusState private var licenseFieldFocused: Bool
  
  @State private var showCameraView = false
  
  init(viewModel: DrivingLicenseViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var body: some View {
    NavigationView {
      ScrollView(showsIndicators: false) {
        VStack(spacing: 50) {
          VStack(spacing: 25) {
            VStack(spacing: 20) {
              VStack(alignment: .leading, spacing: 8) {
                Text("License Picture")
                  .fontWeight(.semibold)
                  .padding(.horizontal, 8)
                RoundedRectangle(cornerRadius: 10)
                  .stroke(
                    Color.black.opacity(0.4),
                    lineWidth: 1.5
                  )
                  .overlay {
                    VStack {
                      if let image = viewModel.licenseImage {
                        image
                          .resizable()
                          .scaledToFit()
                          .padding(.vertical)
                          .padding(.horizontal, 8)
                      } else if let url = viewModel.imageUrl {
                        WebImage(url: url)
                          .resizable()
                          .placeholder {
                            VStack {
                              ProgressView().progressViewStyle(CircularProgressViewStyle())
                              Text("Loading License Image")
                            }
                          }
                          .scaledToFit()
                          .padding(.vertical)
                          .padding(.horizontal, 8)
                      } else {
                        Image(systemName: "creditcard")
                          .font(.system(size: 70))
                          .foregroundColor(.secondary.opacity(0.3))
                      }
                      Button("Scan License", action: presentCamera)
                    }
                  }
                  .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                  .frame(height: 200)
              }
            }
            
            InputFieldContainer(
              isError: !(viewModel.licenseNoValid ?? true),
              label: "License Number"
            ) {
              TextField("12-digit number", text: $viewModel.licenseNo)
                .disableAutocorrection(true)
                .focused($licenseFieldFocused)
                .onChange(
                  of: licenseFieldFocused,
                  perform: viewModel.validateLicenseNoIfFocusIsLost
                )
            }
          }
          .padding(.bottom, 50)
        }
        .padding()
        .cornerRadius(15)
        .padding(.vertical)
      }
      .fullScreenCover(isPresented: $showCameraView) {
        VNDocumentCameraViewController.View(imageData: $viewModel.imageData)
      }
      .background(Color.backgroundColor)
      .navigationBarTitleDisplayMode(.inline)
      .navigationTitle("Driving License")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Save") { presentationMode.wrappedValue.dismiss() }
          .disabled(viewModel.signUpButtonDisabled)
        }
        
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Close") { presentationMode.wrappedValue.dismiss() }
        }
      }
      .edgesIgnoringSafeArea(.bottom)
    }
  }
  
  private func presentCamera() {
    showCameraView.toggle()
  }
}

struct DrivingLicenseView_Previews: PreviewProvider {
  static var previews: some View {
    DrivingLicenseView(viewModel: .init())
  }
}

extension DrivingLicenseViewModel {
  var licenseImage: Image? {
    guard let imageData = imageData,
          let uiImage = UIImage(data: imageData) else {
      return nil
    }
    return Image(uiImage: uiImage)
  }
}
