//
//  NewFoodView.swift
//  FPExercise
//
//  Created by Abhijana Agung Ramanda on 11/10/21.
//

import SwiftUI

struct NewFoodView: View {
  
  @State var txtarea = ""
  
  init() {
    setupNavigationBarAppearance()
  }
  
  var body: some View {
    NavigationView {
      ScrollView(showsIndicators: false) {
        VStack(spacing: 25) {
          InputFieldContainer(
            isError: false,
            label: "Photos",
            semiBoldLabel: false,
            fieldHeight: 100
          ) {
            ScrollView(.horizontal, showsIndicators: false, content: {
              HStack {
                ForEach(0..<4) { _ in
                  RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 70, height: 70)
                }
              }.padding(.leading, 2)
            })
              .overlay(alignment: .trailing) {
                Button(action: { }) {
                  VStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text("Add\nPicture")
                      .font(.caption)
                      .multilineTextAlignment(.center)
                  }
                  .frame(width: 80, height: 95)
                  .background(
                    LinearGradient(
                      gradient: Gradient(
                        stops: [
                          .init(color: .white, location: 0.3),
                          .init(color: .white.opacity(0.5), location: 0.7),
                          .init(color: .white.opacity(0.2), location: 1)
                        ]),
                      startPoint: .trailing,
                      endPoint: .leading)
                  )
                }
              }
          }
          
          
          InputFieldContainer(
            isError: false,
            label: "Name",
            semiBoldLabel: false
          ) {
            TextField("Food's name", text: .constant(""))
              .disableAutocorrection(true)
//              .focused($storeTypeFieldFocused)
//              .onChange(
//                of: storeTypeFieldFocused,
//                perform: viewModel.validateStoreTypeIfFocusIsLost
//              )
          }
          
          InputFieldContainer(
            isError: false,
            label: "Category",
            semiBoldLabel: false
          ) {
            TextField("Select at least 1 category", text: .constant(""))
              .disableAutocorrection(true)
          }
          
          InputFieldContainer(
            isError: false,
            label: "Stock",
            semiBoldLabel: false
          ) {
            TextField("Food's current available stock", text: .constant(""))
              .disableAutocorrection(true)
//              .focused($storeTypeFieldFocused)
//              .onChange(
//                of: storeTypeFieldFocused,
//                perform: viewModel.validateStoreTypeIfFocusIsLost
//              )
          }
          
          VStack(alignment: .leading) {
            InputFieldContainer(
              isError: false,
              label: "Keywords",
              semiBoldLabel: false
            ) {
              TextField("Good keywords make the food searchable", text: .constant(""))
                .disableAutocorrection(true)
            }
            Group {
              Text("Use commas to separate keywords")
            }
            .font(.caption)
            .padding(.leading, 8)
          }
          
          
          InputFieldContainer(
            isError: false,
            label: "Description",
            semiBoldLabel: false,
            fieldHeight: 100
          ) {
            TextEditor(text: .constant(""))
            
          }
          
          VStack(alignment: .leading) {
            HStack {
              InputFieldContainer(
                isError: false,
                label: "Retail Price (IDR)",
                semiBoldLabel: false
              ) {
                TextField("Rp", text: .constant(""))
                  .disableAutocorrection(true)
              }
              
              InputFieldContainer(
                isError: false,
                label: "Disc. Rate",
                semiBoldLabel: false
              ) {
                TextField("20% or higher", text: .constant(""))
                  .disableAutocorrection(true)
                
              }
            }
            Text("The displayed price will be Rp15.000")
              .font(.caption)
              .padding(.leading, 8)
          }
          
          
          
          
          
          
        }
//        .frame(width: UIScreen.main.bounds.width * 0.85, alignment: .leading)
        .padding()
        
      }
      .frame(maxWidth: .infinity)
      .background(Color.backgroundColor)
      .navigationBarBackButtonHidden(true)
      .navigationTitle("New Food")
      .navigationBarTitleDisplayMode(.large)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("\(Image(systemName: "chevron.left"))") { }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {}) {
            Text("Save")
              .fontWeight(.bold)
          }
//          .disabled(true)
        }
      }
      
    }
    
    
  }
  
  private func setupNavigationBarAppearance() {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithTransparentBackground()
    appearance.backgroundColor = UIColor(named: "PrimaryColor")
    UINavigationBar.appearance().standardAppearance = appearance
//    UINavigationBar.appearance().scrollEdgeAppearance = appearance
    UINavigationBar.appearance().tintColor = .darkGray
    
  }
}

struct NewFoodView_Previews: PreviewProvider {
  static var previews: some View {
    NewFoodView()
  }
}
