//
//  SelectCategoryView.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 04/12/21.
//

import SwiftUI

struct SelectCategoryView: View {
  @State fileprivate var availableCategories: [CategoryItem]
  
  @ObservedObject private var viewModel: SelectCategoryViewModel
  
  init(viewModel: SelectCategoryViewModel) {
    self.viewModel = viewModel
    self.availableCategories = FoodCategory.categoriesData.map { category in
      CategoryItem(
        category: category,
        isSelected: viewModel.selectedCategories.contains { category.id == $0.id }
      )
    }
  }
  
  var body: some View {
    // https://stackoverflow.com/a/58876712
    var width = CGFloat.zero
    var height = CGFloat.zero
    return NavigationView {
      GeometryReader { proxy in
        ZStack(alignment: .topLeading) {
          ForEach(availableCategories.indices) { index in
            CategoryItemView(category: availableCategories[index])
              .padding(5)
              .onTapGesture {
                if availableCategories[index].isSelected {
                  viewModel.removeFromCategories(availableCategories[index].category)
                } else {
                  viewModel.addToCategories(availableCategories[index].category)
                }
                
                availableCategories[index].isSelected.toggle()
              }
              .alignmentGuide(.leading) { dimension in
                if (abs(width - dimension.width) > proxy.size.width) {
                  width = 0
                  height -= dimension.height
                }
                let result = width
                if availableCategories[index].category.name == availableCategories.last?.category.name {
                  width = 0 //last item
                } else {
                  width -= dimension.width
                }
                return result
                
              }
              .alignmentGuide(.top) { dimension in
                let result = height
                if availableCategories[index].category.name == availableCategories.last?.category.name {
                  height = 0 // last item
                }
                return result
              }
          }
        }
      }
      .padding()
      .background(Color.backgroundColor)
      .navigationBarTitle(
        viewModel.selectedCategories.isEmpty
          ? "Select category"
          : "\(viewModel.selectedCategories.count) categories selected",
        displayMode: .inline
      )
    }
    
  }
}

class SelectCategoryViewModel: ObservableObject {
  private(set) var selectedCategories = [FoodCategory]()
  
  func addToCategories(_ category: FoodCategory) {
    selectedCategories.append(category)
  }
  
  func removeFromCategories(_ category: FoodCategory) {
    if let index = selectedCategories
        .firstIndex(where: { $0.id == category.id })
    {
      selectedCategories.remove(at: index)
    }
  }
  
  var selectionEmpty: Bool { selectedCategories.isEmpty }
}

private extension SelectCategoryView {
  struct CategoryItem: Identifiable {
    var id: UUID { category.id }
    var category: FoodCategory
    var isSelected = false
  }
  
  struct CategoryItemView: View {
    var category: CategoryItem
    
    var body: some View {
      Text(category.category.name)
        .foregroundColor(category.isSelected ? .white : .black)
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(category.isSelected ? Color.accentColor : .white)
        .clipShape(Capsule())
        .if(!category.isSelected) {
          $0.overlay {
            Capsule().strokeBorder(Color.accentColor, lineWidth: 3)
          }
        }
        .animation(.easeOut, value: category.isSelected)
        .transition(.fade)
    }
  }
}



//struct SelectCategoryView_Previews: PreviewProvider {
//  static var previews: some View {
//    SelectCategoryView(viewModel: .constant(.init()))
//  }
//}


