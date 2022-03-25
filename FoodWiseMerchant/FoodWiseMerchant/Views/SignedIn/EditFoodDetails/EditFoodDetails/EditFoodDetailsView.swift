//
//  EditFoodDetailsView.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 20/02/22.
//

import SwiftUI
import PhotosUI

struct EditFoodDetailsView: View {
  @Environment(\.presentationMode) var presentationMode
  @StateObject private var viewModel: EditFoodViewModel
  @StateObject private var keyboard: KeyboardResponder
  
  @FocusState private var nameFieldFocused: Bool
  @FocusState private var keywordFieldFocused: Bool
  @FocusState private var retailPriceFieldFocused: Bool
  @FocusState private var descriptionFieldFocused: Bool
  @FocusState private var discRateFieldFocused: Bool
  
  private static var selectCategoryViewModel: SelectCategoryViewModel!
  private static var imagePickerView: PHPickerViewController.View!
  
  init(viewModel: EditFoodViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
    _keyboard = StateObject(wrappedValue: KeyboardResponder())
    setupFoodWiseNavigationBarAppearance()
  }
  
  var body: some View {
    ScrollView(showsIndicators: false) {
      VStack(spacing: 25) {
        imageContainerView
        InputFieldContainer(
          isError: !viewModel.nameValid,
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
          isError: !viewModel.categoriesValid,
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
                Self.selectCategoryViewModel = SelectCategoryViewModel(selectedCategories: viewModel.selectedCategories)
                viewModel.showingCategoryPicker.toggle()
              }
            }
        }
        VStack(alignment: .leading) {
          InputFieldContainer(
            isError: !viewModel.keywordValid,
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
              isError: !viewModel.retailPriceValid,
              label: "Retail Price",
              semiBoldLabel: false
            ) {
              TextField(
                "Rp",
                value: $viewModel.retailPrice,
                formatter: viewModel.priceFormatter
              )
              .keyboardType(.numberPad)
              .disableAutocorrection(true)
              .focused($retailPriceFieldFocused)
              .onChange(
                of: retailPriceFieldFocused,
                perform: viewModel.validateRetailPriceIfFocusIsLost
              )
            }
            
            InputFieldContainer(
              isError: !viewModel.discountRateValid,
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
    .frame(maxWidth: .infinity)
    .background(Color.backgroundColor)
    .navigationTitle("Edit Food Details")
    .navigationBarBackButtonHidden(true)
    .navigationBarTitleDisplayMode(.large)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button("Cancel") {
          presentationMode.wrappedValue.dismiss()
        }.disabled(viewModel.loading)
      }
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: submitChanges) {
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
            if retailPriceFieldFocused {
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
    .sheet(isPresented: $viewModel.showingImagePicker, onDismiss: {
      viewModel.validateImage()
      // if `previousIndexAndSelectedImageData` is not nil aka user had decided to change the selected image
      if let previousIndexAndSelectedImageData = viewModel.previousIndexAndSelectedImageData,
         let newSelectedImageData = viewModel.foodImagesData[previousIndexAndSelectedImageData.index].data
      {
        let index = previousIndexAndSelectedImageData.index
        let previousData = previousIndexAndSelectedImageData.data
        if previousData != newSelectedImageData {
          viewModel.foodImagesData[index].isNew = true
        }
      }
      // always reset back before dismissing
      viewModel.previousIndexAndSelectedImageData = nil
    }) {
      Self.imagePickerView
    }
    .sheet(isPresented: $viewModel.showingCategoryPicker, onDismiss: {
      viewModel.selectedCategories = Self.selectCategoryViewModel.selectedCategories
      viewModel.validateCategoriesIfFocusIsLost(false)
    }) {
      SelectCategoryView(viewModel: Self.selectCategoryViewModel)
    }
    .snackBar(
      isShowing: $viewModel.showingSubmitSnackbar,
      text: Text("Saving changes...")
    )
    .snackBar(
      isShowing: $viewModel.showingErrorSnackbar,
      text: Text(viewModel.errorMessage),
      isError: true
    )
    .onReceive(viewModel.$updatedFood.dropFirst()) { _ in
      presentationMode.wrappedValue.dismiss()
    }
  }
  
  private var showingDoneKeyboard: Bool {
    retailPriceFieldFocused || discRateFieldFocused || descriptionFieldFocused
  }
  
  private func submitChanges() {
    viewModel.showingSubmitSnackbar.toggle()
    viewModel.saveChanges()
  }
}

private extension EditFoodDetailsView {
  var imageContainerView: some View {
    VStack(alignment: .leading) {
      InputFieldContainer(
        isError: !viewModel.imageValid,
        label: "Photos",
        semiBoldLabel: false,
        fieldHeight: 100
      ) {
        ScrollView(.horizontal, showsIndicators: false, content: {
          HStack {
            ForEach(viewModel.foodImagesData.indices) { index in
              if let image = viewModel.foodImagesData[index].data?.asImage {
                image
                  .resizable()
                  .scaledToFill()
                  .frame(width: 70, height: 70)
                  .clipShape(RoundedRectangle(cornerRadius: 8))
                  .contextMenu {
                    Button(action: {
                      if let data = viewModel.foodImagesData[index].data {
                        Self.imagePickerView = .init(
                          selectionLimit: 1,
                          imageData: $viewModel.foodImagesData[index].data)
                        viewModel.previousIndexAndSelectedImageData = (
                          index: index,
                          data: data)
                        viewModel.showingImagePicker.toggle()
                      }
                    }) {
                      Label("Change", systemImage: "arrow.triangle.2.circlepath.doc.on.clipboard")
                    }
                    Button(action: {
                      viewModel.removeImageData(at: index)
                      viewModel.validateImage()
                    }) {
                      Label("Delete", systemImage: "trash")
                    }
                  }
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
              Button(action: {
                Self.imagePickerView = .init(
                  selectionLimit: viewModel.photoLimit,
                  imageData: $viewModel.newSelectedImageData)
                viewModel.showingImagePicker.toggle()
              }) {
                VStack(spacing: 8) {
                  Image(systemName: "plus")
                  Text("Add\nPhoto")
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
      if viewModel.photoLimit != 4 {
        Text("Tap and hold on photo to update/remove")
          .font(.caption)
          .padding(.leading, 8)
      }
    }
    
  }
}

//struct EditFoodDetailsView_Previews: PreviewProvider {
//  static var previews: some View {
//    EditFoodDetailsView(viewModel: .init(food: .init(id: "id", name: "Chocolate Ice Cream without topping", imagesUrl: [.init(string: "https://images.herzindagi.info/image/2020/Jun/chocolate-parle-g-ice-cream.jpg")], categories: [.categoriesData[1], .categoriesData[2], .categoriesData[4]], stock: 3, keywords: ["Desert", "sweet", "cold"], description: "Ice cream", retailPrice: 15_000, discountRate: 50, merchantId: "mID")))
//  }
//}
