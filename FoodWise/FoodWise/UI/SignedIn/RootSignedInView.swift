//
//  RootSignedInView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 04/11/21.
//

import SwiftUI

struct RootSignedInView: View {
  
  init() {
    let itemAppearance = UITabBarItemAppearance()
    itemAppearance.selected.iconColor = .darkGray
    itemAppearance.normal.iconColor = .lightGray.withAlphaComponent(0.5)
    
    let appeareance = UITabBarAppearance()
    appeareance.backgroundColor = UIColor(named: "SecondaryColor")
    appeareance.stackedLayoutAppearance = itemAppearance
//    appeareance.inlineLayoutAppearance = itemAppearance
//    appeareance.compactInlineLayoutAppearance = itemAppearance
    
    UITabBar.appearance().standardAppearance = appeareance
//    UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.darkGray], for: .selected)
    
  }
  
  var body: some View {
    TabView {
      HomeView()
        .tabItem {
          
          Label("Home", systemImage: "house")
        }
      
      Text("")
        .tabItem {
          Label("Your Bag", systemImage: "bag.fill")
        }
      
      Text("")
        .tabItem {
          Label("Community", systemImage: "person.3.fill")
        }
      
      MyProfileView()
        .tabItem {
          Label("Settings", systemImage: "gearshape.fill")
        }
    }
//    .accentColor(.init(uiColor: .darkGray))
  }
}

struct RootSignedInView_Previews: PreviewProvider {
  static var previews: some View {
    RootSignedInView()
  }
}
