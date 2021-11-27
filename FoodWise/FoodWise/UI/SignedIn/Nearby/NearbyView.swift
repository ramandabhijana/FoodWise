//
//  NearbyView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 05/11/21.
//

import SwiftUI

struct NearbyView: View {
  
  @State private var viewingMode = "Map"
  
  init() {
    let segmentedAppearance = UISegmentedControl.appearance()
    segmentedAppearance.selectedSegmentTintColor = .darkGray
    segmentedAppearance.setTitleTextAttributes(
      [.foregroundColor: UIColor.white],
      for: .selected)
  }
  
  var body: some View {
    NavigationView {
      ZStack {
        NearbyMapView()
      }
//      .navigationTitle("Nearby")
      
      .navigationBarTitleDisplayMode(.inline)
      .navigationBarHidden(true)
      .overlay(alignment: .top) {
        VStack(spacing: 20) {
          HStack {
            Image(systemName: "location.fill")
            Text("Kesiman, Denpasar").bold()
          }
          .font(.headline)
          
          
          Picker("", selection: $viewingMode) {
            Text("Map").tag("Map")
            Text("List").tag("List")
          }
          .pickerStyle(.segmented)
        }
        .padding(.horizontal)
        .background(LinearGradient.navigationBarBackgroundColor)
        .padding(.top, 48)
        .edgesIgnoringSafeArea(.top)
      }
      .overlay(alignment: .bottom) {
        Button(
          action: { },
          label: {
            RoundedRectangle(cornerRadius: 50)
              .fill(Color.white)
              .frame(width: 170, height: 50)
              .shadow(radius: 10)
              .overlay {
                Text("Within 5 km")
                  .fontWeight(.bold)
              }
              .padding(.bottom)
              .opacity(1)
          }
        )
      }
//      .overlay(alignment: .bottom) {
//        HStack {
//          ForEach(0..<4) { i in
//            ZStack {
//              RoundedRectangle(cornerRadius: 50)
//                .fill(.white)
//              
//              RoundedRectangle(cornerRadius: 50)
//                .strokeBorder(
//                  i == 1 ? Color.accentColor : .secondary,
//                  lineWidth: 3
//                )
//            }
//            .frame(height: 50)
//            .overlay {
//              Text("7 km")
//                .bold()
//                .foregroundColor(i == 1 ? .accentColor : .secondary)
//            }
//          }
//        }
//        .padding(.horizontal)
//        .padding(.bottom)
//        .offset(y: -70)
//      }
    }
    
  }
}

struct NearbyView_Previews: PreviewProvider {
  static var previews: some View {
    NearbyView()
  }
}
