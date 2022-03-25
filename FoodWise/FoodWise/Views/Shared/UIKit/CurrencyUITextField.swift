//
//  CurrencyUITextField.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 24/02/22.
//

import UIKit
import SwiftUI

class CurrencyUITextField: UITextField {
  @Binding private(set) var value: Double
  private let formatter: NumberFormatter
  
  init(formatter: NumberFormatter, value: Binding<Double>) {
    self.formatter = formatter
    _value = value
    super.init(frame: .zero)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func willMove(toSuperview newSuperview: UIView?) {
    super.willMove(toSuperview: newSuperview)
    addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    addTarget(self, action: #selector(resetSelection), for: .allTouchEvents)
    
    keyboardType = .numberPad
//    text = String(Int(value))
//    sendActions(for: .editingChanged)
    DispatchQueue.main.async { [weak self] in
      self?.text = String(Int(self?.value ?? 0.0))
      self?.sendActions(for: .editingChanged)
    }
  }
  
  override func deleteBackward() {
    text = textValue.digits.dropLast().string
    sendActions(for: .editingChanged)
  }
  
  private func setupViews() {
    tintColor = .clear
    font = .systemFont(ofSize: 40, weight: .regular)
  }
  
  @objc private func editingChanged() {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      self.text = self.currency(from: self.decimal)
      self.resetSelection()
      self.value = self.doubleValue
//      self.value = Int(self.doubleValue * 100)
    }
  }
  
  @objc private func resetSelection() {
    selectedTextRange = textRange(from: endOfDocument, to: endOfDocument)
  }
  
  private var textValue: String {
    return text ?? ""
//    String(Int(value))
  }
  
  private var doubleValue: Double {
    return (decimal as NSDecimalNumber).doubleValue
  }
  
  private var decimal: Decimal {
    return textValue.decimal / pow(10, formatter.maximumFractionDigits)
  }
  
  private func currency(from decimal: Decimal) -> String {
    return formatter.string(for: decimal) ?? ""
  }
  
  func updateText(with doubleValue: Double) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
//      let textRange = self.textRange(from: self.beginningOfDocument,
//                                     to: self.endOfDocument)
//      self.replace(textRange!, withText: "20000")
//      self.text = String("20000")
  //    editingChanged()
      self.text = String(Int(doubleValue))
      self.sendActions(for: .editingChanged)
//      self.setNeedsDisplay()
//      self.setNeedsLayout()
    }
    
//    sendActions(for: .editingChanged)
    
//    self.text = self.formatter.string(for: doubleValue)
//    self.setNeedsDisplay()
//    self.resetSelection()
//    self.value = doubleValue
    /*
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      self.text = self.formatter.string(for: doubleValue)
      self.resetSelection()
      self.value = doubleValue
    }
    */
    
  }
  
//  func updateText() {
//    text = formatter.string(for: self.value)
//    text = currency(from: self.decimal)
//    self.resetSelection()
//    self.value = self.doubleValue
//  }
}

extension StringProtocol where Self: RangeReplaceableCollection {
  var digits: Self { filter (\.isWholeNumber) }
}

extension String {
  var decimal: Decimal { Decimal(string: digits) ?? 0 }
}

extension LosslessStringConvertible {
  var string: String { .init(self) }
}
