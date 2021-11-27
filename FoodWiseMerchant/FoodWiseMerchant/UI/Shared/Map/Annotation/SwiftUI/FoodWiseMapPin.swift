//
//  FoodWiseMapPin.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 05/11/21.
//

import SwiftUI

struct FoodWiseMapPin: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.addArc(center: CGPoint(x: rect.width * 0.5,
                                y: rect.height * 0.5),
                radius: rect.width * 0.5,
                startAngle: Angle(degrees: 270),
                endAngle: Angle(degrees: 180),
                clockwise: true)
    
    let control1 = CGPoint(x: 0,
                           y: rect.height * 0.75)
    let control2 = CGPoint(x: rect.width * 0.2,
                           y: rect.height * 0.8)
    path.addCurve(to: CGPoint(x: rect.width * 0.5,
                              y: rect.height),
                  control1: control1,
                  control2: control2)
    
    var transform = CGAffineTransform(translationX: rect.width, y: 0)
    transform = transform.scaledBy(x: -1, y: 1)
    path.addPath(path, transform: transform)
    
    return path
  }
}
