//
//  MerchantHomeView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 04/11/21.
//

import SwiftUI

struct MerchantHomeView: View {
  
  init() {
    setupNavigationBarAppearance()
  }
  
  var body: some View {
    NavigationView {
      ZStack(alignment: .bottom) {
        Color.primaryColor
        
        Image.footerFoods
          .resizable()
          .aspectRatio(contentMode: .fit)
          .opacity(0.2)
        
        Text("Food Wise for Business")
          .font(Font.subheadline)
          .fontWeight(.light)
          .padding(.bottom, 32)
        
        ScrollView(showsIndicators: false) {
          LazyVGrid(
            columns: [
              GridItem(.adaptive(minimum: 90), spacing: 15)
            ],
            alignment: .center,
            spacing: 15
          ) {
            ForEach(MenuButtonModel<Text>.allMenus) { menu in
              
              RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .frame(height: 150)
                .shadow(radius: 1)
                .overlay {
                  VStack(spacing: 10) {
                    Image(systemName: menu.imageSystemName)
                      .symbolRenderingMode(.palette)
                      .foregroundStyle(
                        Color.black,
                        Color.accentColor
                      )
                      .font(.largeTitle)
                    
                    Text(menu.title)
                      .padding(.horizontal)
                      .font(.footnote)
                      .multilineTextAlignment(.center)
                  }
                }
            }
            
          }
          .padding(.horizontal)
          .padding(.vertical)
          .background(Color.backgroundColor)
          .cornerRadius(10)
          .padding(.vertical)
          .frame(
            width: UIScreen.main.bounds.width - 30
          )
          .frame(height: height)
          .onAppear {
            print(UIScreen.main.bounds.height)
          }
        }
        
        
      }
      .background(Color.primaryColor)
      .edgesIgnoringSafeArea(.bottom)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          VStack {
            Text("Pochajjang Korean BBQ").font(.headline)
            Text("Restaurant • Denpasar, Bali").font(.subheadline)
          }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Sign Out", action: signOut)
        }
      }
      
    }
  }
  
  private var height: CGFloat? {
    let height = UIScreen.main.bounds.height
    let plusSizeWidth: CGFloat = 736
    return height >= plusSizeWidth ? height / 1.3 : nil
  }
  
  private func setupNavigationBarAppearance() {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithTransparentBackground()
    appearance.backgroundColor = UIColor(named: "PrimaryColor")
    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
  }
  
  private func signOut() {
    AuthenticationService.shared.signOut()
    NotificationCenter.default.post(name: .signInRequiredNotification,
                                    object: nil)
  }
}

struct MerchantHomeView_Previews: PreviewProvider {
  static var previews: some View {
    MerchantHomeView()
  }
}
