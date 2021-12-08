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
        LazyHStack(spacing: 16) {
          ForEach(viewModel.foodsList) { food in
            NavigationLink {
              LazyView(FoodDetailsView(
                viewModel: .init(food: food,
                                 customerId: rootViewModel.customer?.id,
                                 foodRepository: viewModel.foodRepository))
              )
            } label: {
              FoodCell1(food: food)
            }
          }
          .redacted(reason: viewModel.loading ? .placeholder : [])
        }
        .padding(.horizontal)
        .frame(height: 260)
      }
    }
    .padding(.vertical)
  }
}

//struct HorizontalListView_Previews: PreviewProvider {
//  static var previews: some View {
//    HorizontalListView()
//  }
//}
