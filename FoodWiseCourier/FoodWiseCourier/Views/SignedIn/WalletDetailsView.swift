//
//  WalletDetailsView.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 15/05/22.
//

import SwiftUI
import Introspect

struct WalletDetailsView: View {
  @Environment(\.safeAreaInsets) private var safeAreaInsets
  @EnvironmentObject private var mainViewModel: MainViewModel
  @State private var historyBarOffset: CGFloat = 0
  @State private var navigationBarHeight: CGFloat = 0
  @StateObject private var viewModel: WalletDetailsViewModel
  
  static private var withdrawViewModel: WithdrawViewModel!
  
  init(viewModel: WalletDetailsViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var body: some View {
    ScrollView(showsIndicators: false) {
      VStack(alignment: .leading, spacing: 0) {
        ZStack(alignment: .bottom) {
          Color.backgroundColor
            .offset(y: -(navigationBarHeight + safeAreaInsets.top))
          
          Image.walletPattern
            .resizable()
            .frame(height: 350)
            .background(Color.backgroundColor)
          
          VStack(spacing: 28) {
            RoundedRectangle(cornerRadius: 8)
              .fill(Color.primaryColor)
              .frame(height: 150)
              .shadow(
                color: .black.opacity(0.15),
                radius: 8,
                x: 0,
                y: 8)
              .overlay {
                VStack(spacing: 10) {
                  Text("BALANCE")
                    .font(.callout)
                  Text(viewModel.walletBalanceFormatted)
                    .bold()
                    .font(.title)
                }
              }
            HStack(spacing: 16) {
              Button(action: {
                guard let currentBalance = viewModel.wallet?.balance,
                      let walletId = viewModel.wallet?.id else {
                  return
                }
                let userName = mainViewModel.courier.name
                let userEmail = mainViewModel.courier.email
                Self.withdrawViewModel = WithdrawViewModel(
                  maxAmount: currentBalance,
                  userName: userName,
                  userEmail: userEmail,
                  walletId: walletId,
                  repository: viewModel.repository)
                viewModel.listenTransactionPublisher(
                  Self.withdrawViewModel.$transaction
                    .compactMap({ $0 })
                    .eraseToAnyPublisher())
                viewModel.showingWithdrawSheet = true
              }) {
                RoundedRectangle(cornerRadius: 8)
                  .fill(Color.backgroundColor)
                  .overlay {
                    RoundedRectangle(cornerRadius: 8)
                      .strokeBorder(Color.accentColor, lineWidth: 3)
                  }
                  .overlay {
                    Text("Withdraw").bold()
                  }
              }
              .disabled(viewModel.wallet?.balance ?? 0.0 <= 0.0)
            }
            .frame(height: 44)
            .frame(maxWidth: .infinity)
          }
          .frame(width: UIScreen.main.bounds.width * 0.8)
          .padding(.bottom, 30)
        }
        
        HStack {
          Text("Transaction History").bold()
          Spacer()
          if !viewModel.transactionHistoryIsEmpty {
            Button("View all") { viewModel.showingHistoryView = true }
          }
        }
        .padding([.top, .horizontal])
        .padding(.bottom, 8)
        .background(Color.backgroundColor)
        .offset(
          y: historyBarOffset < 45.0 ? -historyBarOffset + 45.0 : 0
        )
        .overlay(alignment: .top) {
          GeometryReader { proxy -> Color in
            let minY = proxy.frame(in: .global).minY
            DispatchQueue.main.async {
              historyBarOffset = minY - safeAreaInsets.top
            }
            return .clear
          }.frame(width: 0, height: 0)
        }
        .zIndex(1)
        
        LazyVStack(
          alignment: viewModel.transactionHistoryIsEmpty
            ? .center
            : .leading
        ) {
          if viewModel.transactionHistoryIsEmpty {
            VStack {
              Image.emptyFolder
                .resizable()
                .frame(
                  width: UIScreen.main.bounds.width * 0.23,
                  height: UIScreen.main.bounds.width * 0.23
                )
              Text("History will be appeared here")
                .font(.subheadline)
            }
            .frame(height: UIScreen.main.bounds.height * 0.28)
          } else {
            makeTransactionHistoryView(data: Array.init(viewModel.transactionHistory.prefix(5)))
          }
        }
        .padding(.bottom)
      }
      .padding(.bottom)
    }
    .redacted(reason: viewModel.isLoading || viewModel.wallet == nil ? .placeholder : [])
    .onAppear {
      setNavigationBarColor(withStandardColor: .backgroundColor,
                            andScrollEdgeColor: .clear)
      viewModel.loadWallet(userId: mainViewModel.courier.id)
    }
    .introspectNavigationController { controller in
      navigationBarHeight = controller.navigationBar.frame.height
    }
    .sheet(isPresented: $viewModel.showingWithdrawSheet) {
      WithdrawBalanceView(viewModel: Self.withdrawViewModel,
                          showingView: $viewModel.showingWithdrawSheet)
    }
    .sheet(isPresented: $viewModel.showingHistoryView) {
      NavigationView {
        ScrollView {
          LazyVStack(pinnedViews: .sectionHeaders) {
            makeTransactionHistoryView(data: viewModel.transactionHistory)
          }
        }
        .navigationTitle("Transaction History")
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            Button("Close") { viewModel.showingHistoryView = false }
          }
        }
      }
    }
    
  }
  
  private func makeTransactionHistoryView(data: [WalletDetailsViewModel.TransactionHistoryGroupedByDate]) -> some View {
    ForEach(data, id: \.self.id) { history in
      Section(header: {
        return HStack {
          Text(
            WalletDetailsViewModel.historySectionDateFormatter.string(from: history.date)
          )
            .padding(.leading)
            .padding(.vertical, 5)
          Spacer()
        }
        .background(.ultraThinMaterial)
        .frame(maxWidth: .infinity)
      }()) {
        ForEach(history.transactions) { transaction in
          HStack(spacing: 10) {
            VStack(alignment: .leading) {
              Text(transaction.id)
                .foregroundColor(.secondary)
                .font(.caption2)
                .lineLimit(1)
              Text(transaction.info)
                .font(.callout)
            }
            Spacer()
            Text(viewModel.transactionAmountSpentFormated(amount: transaction.amountSpent)).bold()
          }
          .padding()
          .overlay {
            RoundedRectangle(cornerRadius: 15)
              .stroke(Color.gray, lineWidth: 1)
          }
          .padding(.horizontal)
          .padding(.vertical, 8)
        }
      }
    }
  }
  
}
