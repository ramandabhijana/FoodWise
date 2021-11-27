//
//  MyProfileView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 31/10/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct MyProfileView: View {
  
  init() {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithTransparentBackground()
    appearance.backgroundColor = UIColor(named: "PrimaryColor")
    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().tintColor = .black
  }
  
  var body: some View {
    NavigationView {
      ScrollView(showsIndicators: false) {
        LazyVStack(alignment: .leading) {
          // Email field
          VStack(alignment: .leading, spacing: 25) {
            HStack {
              WebImage(url: URL(string: "https://2.bp.blogspot.com/-ZdnLaOpiMoo/WQMdt5AzfdI/AAAAAAAABdA/aP3bOxoU-zw8alU1dw4Yx8s-M9DmSNXxwCEw/s1600/Mitsuki_Infobox.png"))
                .resizable()
                .scaledToFill()
                .frame(width: 55, height: 55)
                .clipShape(Circle())
              
              VStack(alignment: .leading) {
                Text("Abhijana Agung Ramanda")
                  .font(.headline)
                  .lineLimit(2)
                
                Text(verbatim: "abhijanaramanda@gmail.com")
                  .font(.footnote)
                  .fontWeight(.light)
                  .lineLimit(2)
              }
              Spacer()
              Button(
                action: { },
                label: {
                  Image(systemName: "square.and.pencil")
                    .font(.system(size: 24))
                    
                }
              )
            }
            
            VStack(alignment: .leading) {
              Text("Contribution")
                .font(.headline)
              
              RoundedRectangle(cornerRadius: 10)
                .fill(.white.opacity(0.2))
                .shadow(radius: 1)
                .frame(height: 70)
                .overlay {
                  HStack {
                    VStack {
                      Text("20")
                        .font(.title2)
                        .fontWeight(.semibold)
                      Text("Food Rescued")
                        .font(.subheadline)
                    }
                    
                    RoundedRectangle(cornerRadius: 2)
                      .fill(Color.secondary.opacity(0.2))
                      .frame(width: 1, height: 40)
                      .padding(.horizontal)
                    
                    VStack {
                      Text("10")
                        .font(.title2)
                        .fontWeight(.semibold)
                      Text("Food Shared")
                        .font(.subheadline)
                    }
                  }
                  .padding(.horizontal)
                }
            }
            .padding(.top)
            
//            VStack(alignment: .leading) {
//
//              Text("Balance")
//                .font(.headline)
//                .bold()
//
//              NavigationLink(destination: Text("")) {
//                RoundedRectangle(cornerRadius: 10)
//                  .fill(.white.opacity(0.2))
//                  .shadow(radius: 1)
//                  .frame(height: 60)
//                  .overlay {
//                    VStack {
//                      Text(verbatim: "IDR 10.000")
//                        .font(.title2)
//                        .fontWeight(.semibold)
//                        .foregroundColor(.black)
//                    }
//                  }
//                  .overlay(alignment: .trailing) {
//                    Image(systemName: "chevron.right")
//                      .padding(.trailing)
//                  }
//              }
//
//            }
            
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding()
          
          VStack(alignment: .leading, spacing: 25) {
            Text("More")
              .font(.headline)
              .bold()
            SettingsMoreItemView(
              imgSystemName: "banknote",
              title: "Wallet",
              subtitle: "Check your balance, top-up, and more"
            )
            SettingsMoreItemView(
              imgSystemName: "house",
              title: "Shipping Address",
              subtitle: "Manage your shipping address"
            )
            SettingsMoreItemView(
              imgSystemName: "archivebox",
              title: "Order History",
              subtitle: "See what you've ordered in the past"
            )
            
            RoundedRectangle(cornerRadius: 0)
              .fill(Color.secondary.opacity(0.2))
              .frame(
                width: UIScreen.main.bounds.width,
                height: 10
              )
              .position(x: UIScreen.main.bounds.width / 2.17)
              .padding(.top)
            
            HStack {
              Image(systemName: "rectangle.portrait.and.arrow.right")
                .rotation3DEffect(
                  .degrees(180),
                  axis: (x: 0, y:1, z: 0)
                )
              
              VStack(alignment: .leading) {
                Text("Sign Out")
              }
              .padding(.leading)
            }
            
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding()
          
        }
      }
      .background(Color.backgroundColor)
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.inline)
      
      
    }
  }
}

struct MyProfileView_Previews: PreviewProvider {
  static var previews: some View {
    MyProfileView()
  }
}

private extension MyProfileView {
  struct SettingsMoreItemView: View {
    let imgSystemName: String
    let title: String
    let subtitle: String
    
    var body: some View {
      HStack(spacing: 25) {
        Image(systemName: imgSystemName)
        VStack(alignment: .leading) {
          Text(title)
          Text(subtitle)
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
    }
  }
}
