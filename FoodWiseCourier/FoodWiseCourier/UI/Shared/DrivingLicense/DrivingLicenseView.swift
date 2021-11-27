//
//  DrivingLicenseView.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 27/11/21.
//

import SwiftUI

struct DrivingLicenseView: View {
  @State private var licensePicture: Image? = Image("ktm")
  
  
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
                    .if(licensePicture == nil) { view in
                      view.overlay {
                        VStack(spacing: 15) {
                          Image(systemName: "creditcard")
                            .font(.system(size: 70))
                            .foregroundColor(.secondary.opacity(0.3))
                          Text("Tap to add license picture")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                        }
                      }
                    }
                  
                    .overlay {
                      licensePicture?
                        .resizable()
                        .scaledToFit()
                        .padding(.vertical)
                        .padding(.horizontal, 8)
                    }
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                    .frame(height: 200)
                    
                }
              }
              
              InputFieldContainer(
                isError: .constant(false),
                label: "License Number"
              ) {
                TextField("6-digit number", text: .constant(""))
                  .disableAutocorrection(true)
              }
              
              
            }
            .padding(.bottom, 50)
            
//            Button(
//              action: {
//
//              },
//              label: {
//                RoundedRectangle(cornerRadius: 10)
//                  .fill(Color.accentColor)
//                  .frame(height: 48)
//                  .overlay {
//                    Button(
//                      action: { },
//                      label: {
//                        Text("Sign up")
//                          .foregroundColor(.white)
//                      })
//                  }
//              })
            
            
          }
          .padding()
          .cornerRadius(15)
          .padding(.vertical)
        }
      .background(Color.backgroundColor)
      .navigationBarTitleDisplayMode(.inline)
      .navigationTitle("Driving License")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Save") {
            
          }
          .disabled(false)
        }
        
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Close") { }
        }
      }
      .edgesIgnoringSafeArea(.bottom)
    }
  }
}

struct DrivingLicenseView_Previews: PreviewProvider {
  static var previews: some View {
    DrivingLicenseView()
  }
}
