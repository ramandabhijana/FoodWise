//
//  NavigationBarView.swift
//  FPExercise
//
//  Created by Abhijana Agung Ramanda on 13/09/21.
//

import SwiftUI

struct NavigationBarView<ButtonLabel: View>: View {
  let width: CGFloat
  let title: String
  let subtitle: String
  var showTitle: Bool
  var backgroundColor: Color
  var onTapBackButton: () -> ()
  var favoriteButtonLabel: () -> ButtonLabel
  var onTapFavoriteButton: () -> ()
  
  var body: some View {
    HStack {
      backButton
      Spacer()
      VStack {
        Text(title)
          .font(.headline)
        Text(subtitle)
          .font(.subheadline)
      }
      .offset(y: showTitle ? 0 : 65)
      Spacer()
      favoriteButton
    }
    .frame(width: width, height: 48)
    // the live preview won't work if this uncommented
//    .padding(.top, .safeAreaInsetsTop)
    .padding(.top, 48)
    .padding(.horizontal)
    .padding(.bottom, backgroundColor == .clear ? 20 : 5)
    .background(background)
  }
  
  private var backButton: some View {
    let imageName = "chevron.backward"
    return VStack {
      Button(
        action: onTapBackButton,
        label: {
          Image(systemName: imageName)
            .foregroundColor(.init(uiColor: .darkGray))
            .font(.title3)
        })
    }
    .frame(width: width * 0.08, height: width * 0.08)
    .background(backgroundColor == .clear ? Color.white : .clear)
    .clipShape(Circle())
  }
  
  // heart
  private var favoriteButton: some View {
    return VStack {
      Button(action: onTapFavoriteButton, label: favoriteButtonLabel)
    }
    .frame(width: width * 0.08, height: width * 0.08)
    .background(backgroundColor == .clear ? Color.white : .clear)
    .clipShape(Circle())
  }
  
  
  @ViewBuilder private var background: some View {
    if backgroundColor == .clear {
      LinearGradient(
        gradient: Gradient(
          stops: [
            .init(color: .black.opacity(0.4), location: 0.1),
            .init(color: .clear, location: 0.85)
          ]),
        startPoint: .top,
        endPoint: .bottom)
    } else {
      Color.primaryColor
    }
  }
}

//struct NavigationBarView_Previews: PreviewProvider {
//  static var previews: some View {
//    NavigationBarView(
//      width: 400,
//      showTitle: false,
//      backgroundColor: .clear
//    )
//    .previewLayout(.sizeThatFits)
//  }
//}

extension CGFloat {
  static let safeAreaInsetsTop = UIApplication.shared.windows.first!.safeAreaInsets.top
  
  static let safeAreaInsetsBottom =
  UIApplication.shared.windows.first!.safeAreaInsets.bottom
}
