//
//  FoodWiseClusterAnnotationView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 05/11/21.
//

import SwiftUI

struct FoodWiseClusterAnnotationView: View {
  var body: some View {
    Circle()
      .fill(Color.accentColor)
      .frame(width: 45, height: 45)
      .overlay(alignment: .center) {
        Text("99+")
          .foregroundColor(.white)
          .bold()
      }
  }
}

struct FoodWiseClusterAnnotationView_Previews: PreviewProvider {
  static var previews: some View {
    FoodWiseClusterAnnotationView()
  }
}
