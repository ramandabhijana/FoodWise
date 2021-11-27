//
//  NavigationBarView.swift
//  FPExercise
//
//  Created by Abhijana Agung Ramanda on 13/09/21.
//

import SwiftUI

struct NavigationBarView: View {
  let width: CGFloat
  var showTitle: Bool
  var backgroundColor: Color
  
  var body: some View {
    HStack {
      backButton
      Spacer()
      VStack {
        Text("Kentucky Fried Chicken")
        Text("Rp 30.000")
          .bold()
      }
      .offset(y: showTitle ? 0 : 65)
      Spacer()
      VStack(content: EmptyView.init)
        .frame(width: width * 0.08)
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
        action: {},
        label: {
          Image(systemName: imageName)
            .font(.title2)
            .foregroundColor(.black)
        })
    }
    .frame(width: width * 0.08)
    .padding(backgroundColor == .clear ? 4 : .zero)
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

struct NavigationBarView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationBarView(
      width: 400,
      showTitle: false,
      backgroundColor: .clear
    )
    .previewLayout(.sizeThatFits)
  }
}

extension CGFloat {
  static let safeAreaInsetsTop = UIApplication.shared.windows.first!.safeAreaInsets.top
  
  static let safeAreaInsetsBottom = UIApplication.shared.windows.first!.safeAreaInsets.bottom
}
