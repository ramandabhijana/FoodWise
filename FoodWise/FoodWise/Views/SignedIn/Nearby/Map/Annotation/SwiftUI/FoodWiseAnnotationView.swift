//
//  FoodWiseAnnotationView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 05/11/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct FoodWiseAnnotationView: View {
//  @State private var image: URL? = nil {
//    didSet {
//      print("image: \(image)")
//    }
//  }
  
  var imageUrl: URL? = nil
//  {
//    willSet {
//      print("imageUrl about to set to: \(String(describing: newValue))")
//      image = newValue
//    }
//  }
  
//  init(imageUrl: URL? = nil) {
//    self.imageUrl = imageUrl
//    print("\n \(imageUrl) \n")
//  }
  
  var body: some View {
    GeometryReader { proxy in
      FoodWiseMapPin()
        .stroke(style: StrokeStyle(
          lineWidth: proxy.size.width * 0.08,
          lineCap: .round)
        )
        .fill(Color.accentColor)
        .background(
          FoodWiseMapPin().fill(Color.yellow)
        )
        .overlay(image(withSize: proxy.size.width))
//        .overlay {
//          AsyncImage(url: imageUrl) { image in
//            image.resizable()
//          } placeholder: {
//            Circle().fill(Color.backgroundColor)
//          }
//          .frame(
//            width: proxy.size.width * 0.75,
//            height: proxy.size.width * 0.75
//          )
//          .clipShape(Circle())
//
//        }
    }
    .frame(width: 40, height: 60)
  }
  
  private func image(withSize size: CGFloat) -> some View {
    let width = size * 0.75
    return WebImage(url: imageUrl)
      .resizable()
      .placeholder {
        Circle()
          .fill(Color.backgroundColor)
          .frame(width: width, height: width)
      }
      .frame(width: width, height: width)
      .clipShape(Circle())
  }
}

struct Shapes_Previews: PreviewProvider {
    static var previews: some View {
      FoodWiseAnnotationView(imageUrl: nil)
    }
}
