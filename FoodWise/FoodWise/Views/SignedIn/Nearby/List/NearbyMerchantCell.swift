//
//  NearbyMerchantCell.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 10/12/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct NearbyMerchantCell: View {
  var merchant: Merchant
  
  var body: some View {
    RoundedRectangle(cornerRadius: 10)
      .fill(Color.white)
      .frame(height: 110)
      .shadow(radius: 1.5)
      .overlay(alignment: .leading) {
        HStack(alignment: .top, spacing: 20) {
          WebImage(url: merchant.logoUrl)
            .resizable()
            .frame(width: 70, height: 70)
            .scaledToFit()
            .clipShape(Circle())
            .shadow(radius: 1)
          
          VStack(alignment: .leading) {
            Text(merchant.name)
              .foregroundColor(.black)
              .bold()
            HStack {
              Image(systemName: "mappin.and.ellipse")
              Text(merchant.location.geocodedLocation)
            }.font(.footnote)
            Text(merchant.storeType)
              .font(.caption)
              .foregroundColor(.black)
              .padding(3)
              .background(Color.primaryColor.opacity(0.5))
          }
        }
        .padding()
      }
    
  }
}

//struct NearbyMerchantCell_Previews: PreviewProvider {
//  static var previews: some View {
//    NearbyMerchantCell(merchant: <#Merchant#>)
//  }
//}
