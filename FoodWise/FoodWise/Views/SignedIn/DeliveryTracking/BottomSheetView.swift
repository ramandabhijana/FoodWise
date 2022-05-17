//
//  BottomSheetView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 15/04/22.
//

import SwiftUI

enum BottomSheetDisplayType {
  case none, minimized, fullScreen
}

struct BottomSheetView<Content: View>: View {
  @Binding private var displayType: BottomSheetDisplayType
  @GestureState private var translation: CGFloat = 0
  
  private let minHeight: CGFloat = 38.0
  private let minimizedHeight: CGFloat
  private let maxHeight: CGFloat
  private let content: Content
  
  private var offset: CGFloat {
    switch displayType {
    case .fullScreen: return 0
    case .minimized: return maxHeight - minimizedHeight
    case .none: return maxHeight - minHeight
    }
  }
  
  // The offset value that gets animated
  private var offsetY: CGFloat {
    return max(offset + translation, 0)
  }
  
  init(displayType: Binding<BottomSheetDisplayType>,
       minimizedHeight: CGFloat,
       maxHeight: CGFloat,
       @ViewBuilder content: () -> Content) {
    self.minimizedHeight = minimizedHeight
    self.maxHeight = maxHeight
    self.content = content()
    _displayType = displayType
  }
  
  var body: some View {
    GeometryReader { geometry in
      VStack(spacing: 0) {
        makeIndicator()
          .padding()
        content
      }
      .frame(width: geometry.size.width, height: maxHeight, alignment: .top)
      .background(Color.primaryColor)
      .frame(height: geometry.size.height, alignment: .bottom)
      .offset(y: offsetY)
      .animation(.interactiveSpring(), value: offsetY)
      .gesture(
        DragGesture().updating(self.$translation) { value, state, _ in
          state = value.translation.height
        }.onEnded { value in
          let snapDistanceFullScreen = maxHeight * 0.35
          let snapDistanceHalfScreen = maxHeight * 0.85
          if value.location.y <= snapDistanceFullScreen {
            self.displayType = .fullScreen
          } else if value.location.y > snapDistanceFullScreen  &&  value.location.y <= snapDistanceHalfScreen{
            self.displayType = .minimized
          } else {
            self.displayType = .none
          }
        }
      )
    }
  }
  
  private func makeIndicator() -> some View {
    RoundedRectangle(cornerRadius: 16)
      .fill(Color(uiColor: .darkGray))
      .frame(width: 60, height: 6)
  }
}
