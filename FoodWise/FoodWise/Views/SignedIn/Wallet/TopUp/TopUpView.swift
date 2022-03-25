//
//  TopUpView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 24/02/22.
//

import SwiftUI

struct TopUpView: View {
  @EnvironmentObject var rootViewModel: RootViewModel
  @ObservedObject private var viewModel: TopUpViewModel
  @ObservedObject var keyboardResponder: KeyboardResponder = KeyboardResponder()
  @FocusState private var inputFieldFocused: Bool
  
  static private var cardEntryViewModel: CardEntryViewModel!
  
  init(viewModel: TopUpViewModel) {
    self.viewModel = viewModel
//    _viewModel = StateObject(wrappedValue: viewModel)
//    self.currencyField = CurrencyUITextField(
//      formatter: WalletDetailsViewModel.currencyFormatter,
//      value: $viewModel.enteredAmount)
//    self.viewModel.delegate = self.currencyField
  }
  
  var body: some View {
    VStack {
      Spacer()
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.white)
        .frame(height: 350)
        .shadow(radius: 20)
        .overlay(alignment: .topLeading) {
          VStack(alignment: .leading, spacing: 15) {
            Button("\(Image(systemName: "xmark"))") {
              viewModel.showingView = false
            }
            switch viewModel.viewState {
            case .inputAmount:
              Text("Top Up Balance")
                .font(.title)
                .bold()
              VStack(alignment: .leading, spacing: 0) {
                Text("Amount")
                  .padding(.bottom, 5)
                  .padding(.leading, 8)
                CurrencyTextField(
                  numberFormatter: WalletDetailsViewModel.currencyFormatter,
                  value: $viewModel.enteredAmount
                )
//                CurrencyTextField(currencyField: {
//                  let field = CurrencyUITextField(
//                    formatter: WalletDetailsViewModel.currencyFormatter,
//                    value: $viewModel.enteredAmount)
//                  viewModel.delegate = field
//                  return field
//                }())
                  .focused($inputFieldFocused)
                  .frame(height: 20)
                  .padding()
                  .overlay {
                    RoundedRectangle(cornerRadius: 10)
                      .strokeBorder(
                        viewModel.isAmountValid ? Color.gray.opacity(0.3) : .errorColor,
                        lineWidth: 2
                      )
                  }
                if !viewModel.isAmountValid {
                  Text("Minimum: IDR 15.000")
                    .font(.caption)
                    .foregroundColor(.errorColor)
                }
              }
              /*
              HStack {
                ForEach(TopUpViewModel.recommendedAmount, id: \.self) { amount in
                  Button(action: { viewModel.onTapRecommendedAmount(amount) }) {
                    Text(NSNumber(value: amount), formatter: {
                      let formatter = NumberFormatter()
                      formatter.numberStyle = .decimal
                      return formatter
                    }())
                      .font(.subheadline)
                      .padding(.horizontal)
                      .overlay {
                        RoundedRectangle(cornerRadius: 10)
                          .strokeBorder(Color.gray)
                      }
                      .frame(maxWidth: .infinity)
                  }
                }
              }
              */
              Spacer()
              Button(action: viewModel.showConfirmation) {
                RoundedRectangle(cornerRadius: 10)
                  .frame(height: 44)
                  .overlay {
                    Text("Next")
                      .foregroundColor(.white)
                  }
              }
              .disabled(!viewModel.isAmountValid)
//              .padding(.bottom, -(tabBarHeight * 0.5))
            case .confirmation:
              Text("🇮🇩IDR 14.500 → 🇺🇸USD 1.01")
                .bold()
                .padding(.bottom)
              Text("An amount of \(viewModel.enteredAmountString) will be added to your digital wallet balance just as requested.")
              + Text("\nHowever, your Credit Card will be charged in US Dollars for \(viewModel.usdConversion)")
                .fontWeight(.bold)
              Spacer()
              HStack {
                Button(action: { viewModel.showingView = false }) {
                  RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(Color.accentColor, lineWidth: 3)
                    .frame(height: 44)
                    .overlay {
                      Text("Cancel")
                        
                    }
                }
                Button(action: {
                  guard let email = rootViewModel.customer?.email, viewModel.walletId.isEmpty == false else { return }
                  viewModel.showingView = false
                  Self.cardEntryViewModel = CardEntryViewModel(
                    userEmail: email,
                    amount: viewModel.usdAmount)
                  viewModel.listenPaymentPublisher(Self.cardEntryViewModel.paymentPublisher)
                  viewModel.showingCardEntryView = true
                  
                }) {
                  RoundedRectangle(cornerRadius: 10)
                    .frame(height: 44)
                    .overlay {
                      Text("Continue")
                        .foregroundColor(.white)
                    }
                }
              }
            }
            
            
//                .padding(.bottom, 28)
            
            /*
            Text("Top Up Balance")
              .font(.title)
              .bold()
            CurrencyTextField(numberFormatter: numberFormatter, value: $value)
              .frame(height: 20)
              .padding()
              .overlay {
                RoundedRectangle(cornerRadius: 10)
                  .strokeBorder(Color.gray.opacity(0.3), lineWidth: 2)
              }
            
            HStack {
              ForEach(0..<4) { _ in
                Button(action: { }) {
                  Text("30.000")
                    .font(SwiftUI.Font.subheadline)
                    .padding(.horizontal)
                    .overlay {
                      RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.gray)
                    }
                    .frame(maxWidth: .infinity)
                }
              }
            }
            Spacer()
            Button(action: { }) {
              RoundedRectangle(cornerRadius: 10)
                .frame(height: 44)
                .overlay {
                  Text("Next")
                    .foregroundColor(.white)
                }
            }
            .padding(.bottom)
            
            */
          }
          .padding()
          .background(Color.white)
        }
        .animation(.easeIn, value: viewModel.showingView)
    }
    .background(
      Color.gray.opacity(0.5)
        .edgesIgnoringSafeArea(.all)
        .onTapGesture {
          viewModel.showingView = false
        }
    )
    .offset(y: viewModel.showingView ? 0 : UIScreen.main.bounds.height)
    .overlay(alignment: .bottom) {
      if inputFieldFocused {
        HStack {
          Spacer()
          Button("Done") {
            inputFieldFocused = false
          }
        }
        .padding()
        .background(.thinMaterial)
      }
    }
    .fullScreenCover(isPresented: $viewModel.showingCardEntryView) {
      CardEntryView(viewModel: Self.cardEntryViewModel)
        .padding(.bottom, -(keyboardResponder.currentHeight))
    }
//    .overlay {
//      TopUpReceiptView(showingReceipt: $viewModel.showingReceiptView)
//    }
    
  }
}

//struct TopUpView_Previews: PreviewProvider {
//  static var previews: some View {
//    TopUpView()
//  }
//}

//extension CurrencyUITextField: TopUpViewModelDelegate {
//  func didSelectRecommendedAmount(_ amount: Double) {
//    updateText(with: amount)
//  }
//}
