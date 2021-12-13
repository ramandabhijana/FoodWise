//
//  SegmentItemView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 12/12/21.
//

import SwiftUI

struct SegmentItemView: View {
  @Binding var currentTitle: String
  var title: String
  var animation: Namespace.ID
  
  var body: some View {
    Button(action: { currentTitle = title }) {
      VStack(spacing: 5) {
        Text(title)
          .font(.headline)
          .foregroundColor(currentTitle == title ? .init(uiColor: .darkGray) : .black.opacity(0.3))
        // default frame to avoid resizing
          .frame(height: 35)
        
        ZStack {
          Rectangle()
            .fill(Color.clear)
            .frame(height: 4)
          
          if currentTitle == title {
            // Matched Geometry Effect Slide Animation
            Rectangle()
              .fill(Color.init(uiColor: .darkGray))
              .frame(height: 4)
              .matchedGeometryEffect(id: "Tab", in: animation)
          }
          
        }
      }
    }
    .animation(.easeOut, value: currentTitle)
  }
}
