//
//  CurrencyTextField.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 24/02/22.
//

import SwiftUI

struct CurrencyTextField: UIViewRepresentable {
  typealias UIViewType = CurrencyUITextField

  let currencyField: CurrencyUITextField
  
  init(numberFormatter: NumberFormatter, value: Binding<Double>) {
    currencyField = CurrencyUITextField(formatter: numberFormatter,
                                        value: value)
  }
  
  func makeUIView(context: Context) -> CurrencyUITextField {
    return currencyField
  }
  
  func updateUIView(_ uiView: CurrencyUITextField, context: Context) {
  }
}
