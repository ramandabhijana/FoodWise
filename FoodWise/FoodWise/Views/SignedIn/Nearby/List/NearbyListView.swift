//
//  NearbyListView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 10/12/21.
//

import SwiftUI

struct NearbyListView: View {
  @StateObject private var viewModel: NearbyListViewModel
  
  init(viewModel: NearbyListViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var body: some View {
    VStack(spacing: 0) {
      HStack {
        Text(viewModel.headerInfoText)
        Spacer()
        Menu("Radius") {
          Button(NearbyRadius.oneKm.asString) {
            viewModel.onTapRadius(.oneKm)
          }
          Button(NearbyRadius.threeKm.asString) {
            viewModel.onTapRadius(.threeKm)
          }
          Button(NearbyRadius.fiveKm.asString) {
            viewModel.onTapRadius(.fiveKm)
          }
          Button(NearbyRadius.sevenKm.asString) {
            viewModel.onTapRadius(.sevenKm)
          }
        }
        .font(.headline)
      }
      .padding(.horizontal)
      .padding(.vertical, 8)
      .background(Color.primaryColor)
      
      ScrollView(showsIndicators: false) {
        LazyVStack(spacing: 16, pinnedViews: .sectionHeaders) {
          ForEach(viewModel.merchants, id: \.radius) { nearbyMerchants in
            Section(header: makeHeader(nearbyMerchants.radius.asString)) {
              ForEach(
                nearbyMerchants.merchants,
                id: \.id,
                content: buildCell
              )
              .padding(.horizontal)
            }
          }
        }
      }
      .background(Color.backgroundColor)
    }
    .edgesIgnoringSafeArea(.top)
  }
  
  private func buildCell(_ merchant: Merchant) -> some View {
    NearbyMerchantCell(merchant: merchant, buildDestination: LazyView(MerchantDetailsView(viewModel: .init(merchant: merchant))))
  }
  
  private func makeHeader(_ textString: String) -> some View {
    HStack {
      Text(textString)
        .padding(.leading)
        .padding(.vertical, 8)
      Spacer()
    }
    .background(.ultraThickMaterial)
    .frame(maxWidth: .infinity)
  }
}

//struct NearbyListView_Previews: PreviewProvider {
//  static var previews: some View {
//    NearbyListView()
//  }
//}
