//
//  NewFoodView.swift
//  FPExercise
//
//  Created by Abhijana Agung Ramanda on 11/10/21.
//

import SwiftUI
import PhotosUI

struct NewFoodView: View {
//  @EnvironmentObject var manageFoodViewModel: ManageFoodViewModel
  @Environment(\.presentationMode) var presentationMode
  
  @StateObject private var viewModel: NewFoodViewModel
  @StateObject private var keyboard: KeyboardResponder
  
  @FocusState private var nameFieldFocused: Bool
  @FocusState private var stockFieldFocused: Bool
  @FocusState private var keywordFieldFocused: Bool
  @FocusState private var retailPriceFieldFocused: Bool
  @FocusState private var descriptionFieldFocused: Bool
  @FocusState private var discRateFieldFocused: Bool
  
  @State private var showImagePicker = false
  @State private var showCategoryPicker = false
  @State private var showErrorSnackbar = false
  @State private var showSubmitSnackbar = false
  
  private let priceFormatter: NumberFormatter
  private static var selectCategoryViewModel: SelectCategoryViewModel!
  
  init(viewModel: NewFoodViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
    _keyboard = StateObject(wrappedValue: KeyboardResponder())
    priceFormatter = NumberFormatter()
    priceFormatter.numberStyle = .currency
    priceFormatter.locale = Locale(identifier: "id_ID")
    setupNavigationBarAppearance()
  }
  
  var body: some View {
    ScrollView(showsIndicators: false) {
      VStack(spacing: 25) {
        InputFieldContainer(
          isError: !(viewModel.imageValid ?? true),
          label: "Photos",
          semiBoldLabel: false,
          fieldHeight: 100
        ) {
          ScrollView(.horizontal, showsIndicators: false, content: {
            HStack {
              ForEach(viewModel.foodImagesData, id: \.self) { imageData in
                if let image = imageData?.asImage {
                  image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                  RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 70, height: 70)
                }
              }
            }.padding(.leading, 2)
          })
            .if(viewModel.photoLimit != 0) {
              $0.overlay(alignment: .trailing) {
                Button(action: { showImagePicker.toggle() }) {
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
        }
        
        InputFieldContainer(
          isError: !(viewModel.nameValid ?? true),
          label: "Name",
          semiBoldLabel: false
        ) {
          TextField("Food's name", text: $viewModel.name)
            .disableAutocorrection(true)
            .focused($nameFieldFocused)
            .onChange(
              of: nameFieldFocused,
              perform: viewModel.validateNameIfFocusIsLost
            )
        }
        
        InputFieldContainer(
          isError: !(viewModel.categoriesValid ?? true),
          label: "Category",
          semiBoldLabel: false
        ) {
          TextField(
            "Select at least 1 category",
            text: .constant(viewModel.selectedCategoriesName)
          )
            .disabled(true)
            .disableAutocorrection(true)
            .overlay(alignment: .trailing) {
              Button("\(Image(systemName: "chevron.forward"))") {
                Self.selectCategoryViewModel = SelectCategoryViewModel()
                showCategoryPicker.toggle()
              }
            }
        }
        
        InputFieldContainer(
          isError: !(viewModel.stockValid ?? true),
          label: "Stock",
          semiBoldLabel: false
        ) {
          TextField(
            "Food's current available stock",
            value: $viewModel.stock,
            formatter: {
              let formatter = NumberFormatter()
              formatter.numberStyle = .decimal
              return formatter
            }()
          )
            .keyboardType(.numberPad)
            .disableAutocorrection(true)
            .focused($stockFieldFocused)
            .onChange(
              of: stockFieldFocused,
              perform: viewModel.validateStockIfFocusIsLost
            )
        }
        
        VStack(alignment: .leading) {
          InputFieldContainer(
            isError: !(viewModel.keywordValid ?? true),
            label: "Keywords",
            semiBoldLabel: false
          ) {
            TextField("Good keywords make the food searchable", text: $viewModel.keywords)
              .disableAutocorrection(true)
              .focused($keywordFieldFocused)
              .onChange(
                of: keywordFieldFocused,
                perform: viewModel.validateKeywordsIfFocusIsLost
              )
          }
          Text("Use a comma followed by single space to separate keywords")
            .font(.caption)
            .padding(.leading, 8)
        }
        
        
        InputFieldContainer(
          isError: false,
          label: "Description (Optional)",
          semiBoldLabel: false,
          fieldHeight: 150
        ) {
          TextEditor(text: $viewModel.description)
            .disableAutocorrection(true)
            .focused($descriptionFieldFocused)
        }
        
        VStack(alignment: .leading) {
          HStack {
            InputFieldContainer(
              isError: !(viewModel.retailPriceValid ?? true),
              label: "Retail Price",
              semiBoldLabel: false
            ) {
              TextField("Rp", value: $viewModel.retailPrice, formatter: priceFormatter)
                .keyboardType(.numberPad)
                .disableAutocorrection(true)
                .focused($retailPriceFieldFocused)
                .onChange(
                  of: retailPriceFieldFocused,
                  perform: viewModel.validateRetailPriceIfFocusIsLost
                )
            }
            
            InputFieldContainer(
              isError: !(viewModel.discountRateValid ?? true),
              label: "Disc. Rate",
              semiBoldLabel: false
            ) {
              TextField(
                "20% or higher",
                value: $viewModel.discountRate,
                formatter: {
                  let formatter = NumberFormatter()
                  formatter.numberStyle = .decimal
                  return formatter
                }()
              )
                .keyboardType(.numberPad)
                .disableAutocorrection(true)
                .focused($discRateFieldFocused)
                .onChange(
                  of: discRateFieldFocused,
                  perform: viewModel.validateDiscountRateIfFocusIsLost
                )
            }
          }
          Text(viewModel.displayedPriceText)
            .font(.caption)
            .padding(.leading, 8)
        }
        
      }
      .padding()
      .padding(.bottom, keyboard.currentHeight * 0.3)
    }
    
//    .padding(.bottom, keyboard.currentHeight)
//    .animation(.easeOut, value: keyboard.currentHeight)
//    .padding(.bottom, keyboard.currentHeight * 0.3)
    .frame(maxWidth: .infinity)
    .background(Color.backgroundColor)
    .navigationBarBackButtonHidden(true)
    .navigationTitle("New Food")
    .navigationBarTitleDisplayMode(.large)
    .onReceive(viewModel.$createdFood.compactMap { $0 }) { _ in
      presentationMode.wrappedValue.dismiss()
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button("Cancel") {
          presentationMode.wrappedValue.dismiss()
        }.disabled(viewModel.loading)
      }
      
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: submit) {
          if viewModel.loading {
            ProgressView()
          } else {
            Text("Save").fontWeight(.bold)
          }
        }
        .disabled(viewModel.buttonDisabled)
      }
    }
    .overlay(alignment: .bottom) {
      if showingDoneKeyboard {
        HStack {
          Spacer()
          Button("Done") {
            if stockFieldFocused {
              stockFieldFocused.toggle()
            } else if retailPriceFieldFocused {
              retailPriceFieldFocused.toggle()
            } else if discRateFieldFocused {
              discRateFieldFocused.toggle()
            } else if descriptionFieldFocused {
              descriptionFieldFocused.toggle()
            }
          }
        }
        .padding()
        .background(.thinMaterial)
      }
    }
    .sheet(isPresented: $showImagePicker, onDismiss: {
      viewModel.validateImageIfFocusIsLost(false)
    }) {
      PHPickerViewController.View(
        selectionLimit: viewModel.photoLimit,
        imageData: $viewModel.selectedFoodImageData
      )
    }
    .sheet(isPresented: $showCategoryPicker, onDismiss: {
      viewModel.selectedCategories = Self.selectCategoryViewModel.selectedCategories
      viewModel.validateCategoriesIfFocusIsLost(false)
    }) {
      SelectCategoryView(viewModel: Self.selectCategoryViewModel)
    }
    .snackBar(
      isShowing: $showSubmitSnackbar,
      text: Text("Saving record...")
    )
    .snackBar(
      isShowing: $showErrorSnackbar,
      text: Text(viewModel.errorMessage),
      isError: true
    )
    
    
  }
  
  private var bottomPaddingIfDoneKeyboardAppeared: CGFloat? {
    showingDoneKeyboard ? 30 : nil
  }
  
  private var showingDoneKeyboard: Bool {
    stockFieldFocused || retailPriceFieldFocused || discRateFieldFocused || descriptionFieldFocused
  }
  
  private func submit() {
    showSubmitSnackbar.toggle()
    viewModel.saveFood()
  }
  
  private func setupNavigationBarAppearance() {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithTransparentBackground()
    appearance.backgroundColor = UIColor(named: "PrimaryColor")
    UINavigationBar.appearance().standardAppearance = appearance
//    UINavigationBar.appearance().scrollEdgeAppearance = appearance
//    UINavigationBar.appearance().tintColor = .darkGray
    
  }
}

//struct NewFoodView_Previews: PreviewProvider {
//  static var previews: some View {
//    NewFoodView(viewModel: .init(merchantId: ""))
//  }
//}
