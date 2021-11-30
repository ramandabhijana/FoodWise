//
//  Snackbar.swift
//  Recipedia
//
//  Created by Abhijana Agung Ramanda on 23/11/20.
//
// Credit to https://github.com/Zi0P4tch0/Swift-UI-Views
import SwiftUI

public struct Snackbar: View {
  @Binding var isShowing: Bool
  private let presenting: AnyView
  private let text: Text
  private let isErrorAlert: Bool
  
  init<Presenting>(isShowing: Binding<Bool>,
                   presenting: Presenting,
                   text: Text,
                   isErrorAlert: Bool) where Presenting: View {
    
    self._isShowing = isShowing
    self.presenting = AnyView(presenting)
    self.text = text
    self.isErrorAlert = isErrorAlert
    
  }
  
  public var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .center) {
        self.presenting
        VStack {
          Spacer()
          if self.isShowing {
            HStack {
              self.text.foregroundColor(.white)
              Spacer()
            }
            .padding()
            .frame(width: geometry.size.width * 0.9)
            .shadow(radius: 3)
            .background(isErrorAlert ?
                          Color.errorColor :
                          Color.black.opacity(0.8)
            )
            .offset(x: 0, y: -20)
            .onAppear {
              let deadline: DispatchTime = .now() + (isErrorAlert ? 4 : 2)
              DispatchQueue.main.asyncAfter(deadline: deadline) {
                withAnimation { self.isShowing = false }
              }
            }
          }
        }
      }
    }
  }
}

extension View {
  public func snackBar(isShowing: Binding<Bool>,
                       text: Text,
                       isError: Bool = false) -> some View {
    Snackbar(isShowing: isShowing,
             presenting: self,
             text: text,
             isErrorAlert: isError)
  }
  
}
