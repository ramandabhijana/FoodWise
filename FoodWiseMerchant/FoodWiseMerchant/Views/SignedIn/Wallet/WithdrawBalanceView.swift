//
//  WithdrawBalanceView.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 14/05/22.
//

import SwiftUI

struct WithdrawBalanceView: View {
  private enum InputField: Hashable {
    case amount, bankName, accountNumber, accountHolder
  }
  
  @ObservedObject private var viewModel: WithdrawViewModel
  @Binding private var showingView: Bool
  @FocusState private var focusedField: InputField?
  
  init(viewModel: WithdrawViewModel, showingView: Binding<Bool>) {
    self.viewModel = viewModel
    _showingView = showingView
  }
  
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(alignment: .leading, spacing: 25) {
          RoundedRectangle(cornerRadius: 8)
            .fill(Material.thinMaterial)
            .frame(height: 110)
            .shadow(radius: 2)
            .overlay(alignment: .topLeading) {
              VStack(alignment: .leading, spacing: 8) {
                Text("Amount")
                  .font(.subheadline)
                CurrencyTextField(
                  numberFormatter: WalletDetailsViewModel.currencyFormatter,
                  value: $viewModel.enteredAmount
                )
                  .focused($focusedField, equals: .amount)
                  .frame(height: 15)
                  .padding()
                  .background(Color.white)
                  .cornerRadius(10)
                  .overlay {
                    RoundedRectangle(cornerRadius: 10)
                      .strokeBorder(
                        viewModel.isAmountValid ?? true ? Color.gray.opacity(0.3) : .red,
                        lineWidth: 2
                      )
                  }
              }
              .padding()
            }
          
          VStack(alignment: .leading) {
            Text("Bank Details").bold()
            VStack(alignment: .leading, spacing: 22) {
              VStack(alignment: .leading, spacing: 8) {
                Text("Bank Name")
                  .font(.subheadline)
                TextField("eg Bank BCA", text: $viewModel.bankName)
                  .focused($focusedField, equals: .bankName)
                  .frame(height: 15)
                  .padding()
                  .background(Color.white)
                  .cornerRadius(10)
                  .overlay {
                    RoundedRectangle(cornerRadius: 10)
                      .strokeBorder(
                        viewModel.isBankNameValid ?? true ? Color.gray.opacity(0.3) : .red,
                        lineWidth: 2
                      )
                  }
              }
              
              VStack(alignment: .leading, spacing: 8) {
                Text("Account number")
                  .font(.subheadline)
                TextField("eg 1232318291", text: $viewModel.accountNumber)
                  .focused($focusedField, equals: .accountNumber)
                  .keyboardType(.numberPad)
                  .frame(height: 15)
                  .padding()
                  .background(Color.white)
                  .cornerRadius(10)
                  .overlay {
                    RoundedRectangle(cornerRadius: 10)
                      .strokeBorder(
                        viewModel.accountNumberValid ?? true ? Color.gray.opacity(0.3) : .red,
                        lineWidth: 2
                      )
                  }
                if !(viewModel.accountNumberValid ?? true) {
                  Text("Must be 10-digit or more")
                    .font(.caption)
                    .foregroundColor(.errorColor)
                }
              }
              
              VStack(alignment: .leading, spacing: 8) {
                Text("Account holder")
                  .font(.subheadline)
                TextField("eg John Doe", text: $viewModel.accountHolder)
                  .focused($focusedField, equals: .accountHolder)
                  .frame(height: 15)
                  .padding()
                  .background(Color.white)
                  .cornerRadius(10)
                  .overlay {
                    RoundedRectangle(cornerRadius: 10)
                      .strokeBorder(
                        viewModel.accountHolderValid ?? true ? Color.gray.opacity(0.3) : .red,
                        lineWidth: 2
                      )
                  }
              }
            }
            .padding()
            .background(
              RoundedRectangle(cornerRadius: 8)
                .fill(Material.thinMaterial)
//                .frame(height: 300)
                .shadow(radius: 2)
            )
          }
          
        }
        .padding()
        .padding(.bottom, 48)
      }
      .navigationTitle("Withdraw Balance")
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Close") {
            showingView = false
          }
        }
      }
      .overlay {
        if viewModel.isLoading {
          ZStack {
            Color.black.opacity(0.5)
              .frame(height: UIScreen.main.bounds.height * 1.5)
            HStack(spacing: 10) {
              ProgressView()
                .progressViewStyle(
                  CircularProgressViewStyle(tint: .black)
                )
              Text("Please wait...")
            }
            .padding()
            .background(.thinMaterial)
            .cornerRadius(8)
          }
        }
      }
      .overlay(alignment: .bottom) {
        if let focusedField = focusedField,
           focusedField == .accountNumber || focusedField == .amount
        {
          HStack {
            Spacer()
            Button("Done") {
              self.focusedField = nil
            }
          }
          .padding()
          .background(.thinMaterial)
        }
      }
      .overlay(alignment: .bottom) {
        if focusedField == nil {
          Button(action: viewModel.onTapSubmitButton) {
            Rectangle()
              .frame(height: 44)
              .overlay {
                Text("Submit")
                  .foregroundColor(.white)
              }
          }
          .disabled(viewModel.buttonDisabled)
        }
      }
      .alert(isPresented: $viewModel.showingSuccessAlert) {
        Alert(
          title: Text("Request sent successfully"),
          message: Text("Kindly check your email for further information"),
          dismissButton: .default(Text("Dismiss"), action: {
            showingView = false
          })
        )
      }
      .snackBar(isShowing: $viewModel.showingErrorAlert,
                text: Text("Something went wrong"),
                isError: true)
    }
  }
}
