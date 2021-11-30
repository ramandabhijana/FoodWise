//
//  Star.swift
//  FPExercise
//
//  Created by Abhijana Agung Ramanda on 30/09/21.
//

import SwiftUI

@available(iOS 15.0, *)
struct StarView: View {
  var body: some View {
    ZStack {
      Color.black
      
      Star(smoothness: 0.4)
        .fill(Color.accentColor)
        .frame(width: 300, height: 300)
        .overlay(alignment: .center) {
          Star(smoothness: 0.4)
            .fill(Color.primaryColor)
            .frame(width: 250, height: 250)
            .offset(y: 2)
        }
      
    }
    
  }
}

struct Star: Shape {
  let smoothness: CGFloat
  var corners = 5
  
  func path(in rect: CGRect) -> Path {
    
    let center = CGPoint(x: rect.midX, y: rect.midY)
    
    // start from upwards
    var currentAngle = -(CGFloat.pi * 0.5)
    
    // number to move with each star corner
    let angleAdjustment = .pi * 2 / CGFloat(5 * 2)
    
    // figure out how much we need to move x and y for the inner points
    let innerX = center.x * smoothness
    let innerY = center.y * smoothness
    
    var path = Path()
    
    path.move(to: CGPoint(
      x: center.x * cos(currentAngle),
      y: center.y * sin(currentAngle))
    )
    
    // keep track the lowest point we draw to
    // to center later
    var bottomEdge = CGFloat.zero
    
    for corner in 0..<corners * 2 {
      let sinAngle = sin(currentAngle)
      let cosAngle = cos(currentAngle)
      let bottom: CGFloat
      
      // means we're drawing the outer edge of the star
      if corner % 2 == 0 {
        
        // store the y position
        bottom = center.y * sinAngle
        
        path.addLine(to: CGPoint(
          x: center.x * cosAngle,
          y: bottom))
        
      } else {
        // we're drawing inner point
        
        bottom = innerY * sinAngle
        
        path.addLine(to: CGPoint(
          x: innerX * cosAngle,
          y: bottom))
      }
      
      // if the new bottom point is our lowst, store it for later
      if bottom > bottomEdge {
        bottomEdge = bottom
      }
      
      // move on to the next corner
      currentAngle += angleAdjustment
    }
    
    let unusedSpaceAtBottom = (rect.height * 0.5 - bottomEdge) * 0.5
    let transform = CGAffineTransform(translationX: center.x,
                                      y: center.y + unusedSpaceAtBottom)
    
    return path.applying(transform)
  }
}

@available(iOS 15.0, *)
struct Star_Previews: PreviewProvider {
  static var previews: some View {
    StarView()
  }
}
