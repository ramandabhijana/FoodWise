//
//  ManageFoodStockView.swift
//  FPExercise
//
//  Created by Abhijana Agung Ramanda on 10/10/21.
//

import SwiftUI

@available(iOS 15.0, *)
struct ManageFoodStockView: View {
  
  init() {
    setupNavigationBarAppearance()
  }
  
  var body: some View {
    NavigationView {
      ZStack {
        Color.backgroundColor
        Text("Tap the + button\nto begin with")
          .multilineTextAlignment(.center)
          
      }
      .ignoresSafeArea()
      .navigationTitle("Manage Food Stock")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Menu("\(Image(systemName: "plus"))") {
            Button("New Food") { }
            Button("New Stock") { }
          }
        }
        
        ToolbarItem(placement: .navigationBarLeading) {
          Button(
            action: { },
            label: {
              Text("Cancel")
                .foregroundColor(.black)
            })
        }
        
        ToolbarItem(placement: .bottomBar) {
          Button(
            action: { },
            label: {
              RoundedRectangle(cornerRadius: 10)
                .fill(Color.accentColor)
                .frame(
                  width: UIScreen.main.bounds.width - 30,
                  height: 44
                )
                .overlay {
                  Text("Submit")
                    .foregroundColor(.white)
                }
              
            })
        }
      }
      
    }
  }
  
  private func setupNavigationBarAppearance() {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithTransparentBackground()
    appearance.backgroundColor = UIColor(named: "Color")
    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
    UINavigationBar.appearance().tintColor = .black
    
  }
}

@available(iOS 15.0, *)
struct ManageFoodStock_Previews: PreviewProvider {
  static var previews: some View {
    ManageFoodStockView()
  }
}
