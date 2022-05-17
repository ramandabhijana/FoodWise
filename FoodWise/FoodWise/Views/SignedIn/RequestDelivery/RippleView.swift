//
//  RippleView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 05/04/22.
//

import SwiftUI

struct Ripple {
  var diameter: CGFloat
  var opacity: Double = 1.0
}

struct RippleView: View {
  @State private var ripple1: Ripple
  @State private var ripple2: Ripple
  @State private var ripple3: Ripple
  
  let finalDiameterRipple1: Double
  let finalDiameterRipple2: Double
  let finalDiameterRipple3: Double
  
  init(initialDiameter: CGFloat, finalDiameter: CGFloat) {
    let initialDiameterRipple3 = Ripple(diameter: initialDiameter)
    let initialDiameterRipple2 = Ripple(diameter: initialDiameter*0.68)
    let initialDiameterRipple1 = Ripple(diameter: initialDiameter*0.33)
    
    finalDiameterRipple3 = finalDiameter
    finalDiameterRipple2 = finalDiameter*0.75
    finalDiameterRipple1 = finalDiameter*0.5
    
    _ripple1 = State(initialValue: initialDiameterRipple1)
    _ripple2 = State(initialValue: initialDiameterRipple2)
    _ripple3 = State(initialValue: initialDiameterRipple3)
  }
  
  var body: some View {
    ZStack {
      Circle()
        .fill(Color(uiColor: .lightGray).opacity(ripple1.opacity))
        .frame(width: ripple1.diameter, height: ripple1.diameter)
        .onAppear {
          withAnimation(Animation.linear(duration: 2.5).repeatForever(autoreverses: false)) {
            ripple1.diameter = finalDiameterRipple1
            ripple1.opacity = 0.15
          }
        }
      Circle()
        .fill(Color(uiColor: .lightGray).opacity(ripple2.opacity))
        .frame(width: ripple2.diameter, height: ripple2.diameter)
        .onAppear {
          withAnimation(Animation.linear(duration: 2.5).repeatForever(autoreverses: false)) {
            ripple2.diameter = finalDiameterRipple2
            ripple2.opacity = 0.1
          }
        }
      Circle()
        .fill(Color(uiColor: .lightGray).opacity(ripple3.opacity))
        .frame(width: ripple3.diameter, height: ripple3.diameter)
        .onAppear {
          withAnimation(Animation.linear(duration: 2.5).repeatForever(autoreverses: false)) {
            ripple3.diameter = finalDiameterRipple3
            ripple3.opacity = 0.05
          }
        }
    }
    
  }
}

struct RippleView_Previews: PreviewProvider {
  static var previews: some View {
    RippleView(initialDiameter: 60, finalDiameter: 400)
  }
}
