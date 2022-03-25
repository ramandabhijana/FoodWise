//
//  NearbyMerchantCell.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 10/12/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct NearbyMerchantCell<Destination: View>: View {
  var merchant: Merchant?
  let buildDestination: (() -> Destination)?
  
  init(
    merchant: Merchant?,
    buildDestination: @autoclosure @escaping () -> Destination
  ) {
    self.merchant = merchant
    self.buildDestination = buildDestination
  }
  
  init(merchant: Merchant?) {
    self.merchant = merchant
    self.buildDestination = nil
  }
  
  var body: some View {
    if let buildDestination = buildDestination {
      NavigationLink(
        destination: LazyView(buildDestination()),
        label: buildView
      )
      .disabled(merchant == nil)
    } else {
      buildView()
    }
  }
  
  private func buildView() -> some View {
    RoundedRectangle(cornerRadius: 10)
      .fill(Color.white)
      .frame(height: 110)
      .shadow(radius: 1.5)
      .overlay(alignment: .leading) {
        HStack(alignment: .top, spacing: 20) {
          WebImage(url: merchant?.logoUrl)
            .resizable()
            .frame(width: 70, height: 70)
            .scaledToFit()
            .clipShape(Circle())
            .shadow(radius: 1)
          
          VStack(alignment: .leading) {
            Text(merchant?.name ?? "Name of merchants")
              .foregroundColor(.black)
              .bold()
            HStack {
              Image(systemName: "mappin.and.ellipse")
              Text(merchant?.location.geocodedLocation ?? "Store Location")
            }
            .font(.footnote)
            .foregroundColor(.black)
            Text(merchant?.storeType ?? "Store type")
              .font(.caption)
              .foregroundColor(.black)
              .padding(3)
              .background(Color.primaryColor.opacity(0.5))
          }
        }
        .padding()
      }
      .redacted(reason: merchant == nil ? .placeholder : [])
  }
}

