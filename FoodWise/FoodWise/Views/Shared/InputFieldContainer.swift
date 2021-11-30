//
//  InputFieldContainer.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 27/11/21.
//

import SwiftUI

public struct InputFieldContainer<C>: View where C: View {
  var isError: Bool
  var label: String
  var contentBuilder: () -> C
  
  public var body: some View {
    VStack(spacing: 20) {
      VStack(alignment: .leading, spacing: 8) {
        Text(label)
          .fontWeight(.semibold)
          .padding(.horizontal, 8)
          .foregroundColor(isError ? .errorColor : .black)
        RoundedRectangle(cornerRadius: 10)
          .stroke(
            isError ? Color.errorColor : .black.opacity(0.4),
            lineWidth: 1.5
          )
          .overlay {
            contentBuilder()
              .padding(.vertical)
              .padding(.horizontal, 8)
          }
          .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
          .frame(height: 45)
          .if(isError) { view in
            view.overlay(alignment: .trailing) {
              Image(systemName: "exclamationmark.circle.fill")
                .padding(.trailing)
                .foregroundColor(.errorColor)
            }
          }
      }.animation(.easeOut, value: isError)
    }
  }
}
