//
//  HorizontalListView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 06/12/21.
//

import SwiftUI

struct HorizontalListView: View {
  @EnvironmentObject private var rootViewModel: RootViewModel
  @StateObject private var viewModel: HomeHorizontalListViewModel
  private var sectionName: String
  
  init(sectionName: String,
       viewModel: HomeHorizontalListViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
    self.sectionName = sectionName
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      Text(sectionName)
        .font(.headline)
        .padding(.leading)
      ScrollView(.horizontal, showsIndicators: false) {
        if viewModel.foodsList.isEmpty {
          VStack {
            Image("empty_list")
              .resizable()
              .scaledToFit()
              .frame(width: 100, height: 100)
            Text("No results can be shown").font(.subheadline)
          }
          .frame(width: UIScreen.main.bounds.width)
        } else {
          LazyHStack(spacing: 16) {
            ForEach(viewModel.foodsList) { food in
              FoodCell1(
                food: food,
                isLoading: viewModel.loading,
                buildDestination: FoodDetailsView(
                  viewModel: .init(
                    food: food,
                    customerId: rootViewModel.customer?.id,
                    foodRepository: viewModel.foodRepository
                  )
                )
              )
              /*
              NavigationLink {
                LazyView(FoodDetailsView(
                  viewModel: .init(food: food,
                                   customerId: rootViewModel.customer?.id,
                                   foodRepository: viewModel.foodRepository))
                )
              } label: {
                FoodCell1(food: food, isLoading: viewModel.loading)
                  .frame(width: 140)
//                  .redacted(reason: viewModel.loading ? .placeholder : [])
              }.disabled(viewModel.loading)
              */
            }
            
//            .disabled(viewModel.loading)
          }
          .padding(.horizontal)
          .frame(height: 260)
        }
      }
    }
    .padding(.vertical)
  }
}

//struct HorizontalListView_Previews: PreviewProvider {
//  static var previews: some View {
//    HorizontalListView(sectionName: "Preview", viewModel: .init(foodRepository: .init()))
//  }
//}
