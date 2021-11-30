//
//  CategoryButton.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 03/11/21.
//

import SwiftUI

struct CategoryButton: View {
//  @Binding var selected: Bool
//  @State private var selected: Bool = false
  var model: CategoryButtonModel
  let index: Int
  @Binding var currentSelectedIndex: Int?
  
  
  
  var body: some View {
    VStack {
      model.image
        .resizable()
        .frame(
//          width: 40,
//          height: 40
          width: UIScreen.main.bounds.width * 0.08,
          height: UIScreen.main.bounds.width * 0.08
        )
        .padding()
        .background(index == currentSelectedIndex ? Color.accentColor : .white)
        .cornerRadius(20)
        .shadow(radius: 1)
        .padding(.top, 1)
        .animation(.easeOut, value: currentSelectedIndex)
      Text(model.name)
        .lineLimit(2)
        .multilineTextAlignment(.center)
        .font(.caption)
    }
//    .frame(width: 70)
  }
}

struct CategoryButton_Previews: PreviewProvider {
  static var previews: some View {
    CategoryButton(
      model: .data[0],
      index: 0,
      currentSelectedIndex: .constant(nil)
    )
  }
}
