//
//  DrawerMenuButton.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 16/03/22.
//

import SwiftUI

struct DrawerMenuButton: View {
  var menu: CourierDrawerMenu
  
  @Binding var currentSelectedMenu: CourierDrawerMenu
  
  var body: some View {
    Button(action: updateCurrentSelectedMenu) {
      HStack(spacing: 15) {
        Image(systemName: menu.imageSystemName)
          .font(.title2)
          .foregroundColor(.init(uiColor: .darkGray))
        Text(menu.rawValue)
          .foregroundColor(.accentColor)
          .bold()
      }
      .padding(.vertical, 12)
      .frame(width: 200, alignment: .leading)
    }
  }
  
  private var selected: Bool { currentSelectedMenu == menu }
  
  func updateCurrentSelectedMenu() {
    currentSelectedMenu = menu
  }
}
