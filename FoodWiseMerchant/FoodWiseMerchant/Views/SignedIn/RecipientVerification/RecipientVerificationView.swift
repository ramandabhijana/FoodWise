//
//  RecipientVerificationView.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 14/05/22.
//

import SwiftUI

struct RecipientVerificationView: View {
  @EnvironmentObject var mainViewModel: MainViewModel
  @StateObject private var viewModel: RecipientVerificationViewModel
  @State private var scanLineOffset: CGFloat = Self.initialLineOffset
  @Environment(\.dismiss) var dismiss
  
  private static let initialLineOffset: CGFloat = UIScreen.main.bounds.height * -0.4
  private static let endLineOffset: CGFloat = initialLineOffset * -1.0
  private static var recipientViewModel: LegitimateRecipientViewModel!
  
  private var scanLine: some View {
    VStack(spacing: 0) {
      LinearGradient(
        colors: [.accentColor.opacity(0.2),
                 .accentColor.opacity(0.1),
                 .accentColor.opacity(0.0)],
        startPoint: .bottom,
        endPoint: .top
      ).frame(height: 80)
      Rectangle()
        .fill(Color.accentColor)
        .frame(height: 6)
    }
  }
  
  init() {
    _viewModel = StateObject(wrappedValue: RecipientVerificationViewModel())
    
  }
  
  var body: some View {
    NavigationView {
      if viewModel.pendingOrders == nil {
        loadingPlaceholder
          .onAppear {
            viewModel.loadPendingOrders(merchantId: mainViewModel.merchant.id)
          }
          .navigationBarHidden(true)
      } else {
        ZStack {
          QRScanViewController.View(viewModel: viewModel)
            .ignoresSafeArea()
          scanLine
            .offset(y: scanLineOffset)
            .animation(
              .easeInOut(duration: 1.8).repeatForever(autoreverses: false),
              value: scanLineOffset
            )
        }
        .overlay(alignment: .top) {
          Rectangle()
            .fill(
              LinearGradient(
                colors: [.black.opacity(0.2),
                         .black.opacity(0.15),
                         .black.opacity(0.0)],
                startPoint: .top,
                endPoint: .bottom)
            )
            .frame(height: 100)
            .edgesIgnoringSafeArea(.top)
        }
        .overlay(alignment: .bottom) {
          Text("Place the QR Code inside the frame")
            .foregroundColor(.white)
            .padding()
            .background(UIBlurEffect.View(blurStyle: .systemThinMaterialDark))
            .cornerRadius(10)
            .padding(.bottom)
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            Image(systemName: "xmark")
              .font(.footnote.bold())
              .padding(5)
              .background(Circle().fill(.thickMaterial))
          }
          ToolbarItem(placement: .principal) {
            Text("Order Verification")
              .font(.title3.bold())
              .foregroundColor(.white)
          }
        }
        .onAppear {
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            scanLineOffset = Self.endLineOffset
          }
        }
        .alert(
          "Invalid QR Code",
          isPresented: $viewModel.showingInvalidCodeAlert
        ) {
          Button("Try Again", action: viewModel.rerunQrCaptureSession)
        }
        .onReceive(NotificationCenter.default.publisher(
          for: RecipientVerificationViewModel.didFinishVerificationNotification)) { _ in
            dismiss()
        }
        .onReceive(viewModel.qrCodeValidForOrderPublisher) { order in
          Self.recipientViewModel = LegitimateRecipientViewModel(
            order: order,
            lineItems: viewModel.makeLineItems(fromOrderLineItems: order.items),
            priceSection: viewModel.makePriceSection(subtotal: order.subtotal, deliveryCharge: order.deliveryCharge, total: order.total))
          viewModel.showingReceiptVerified = true
        }
        .sheet(isPresented: $viewModel.showingReceiptVerified) {
          LegitimateRecipientView(
            viewModel: Self.recipientViewModel,
            onTapRetry: {
              viewModel.showingReceiptVerified = false
              viewModel.rerunQrCaptureSession()
            },
            onTapFinish: {
              viewModel.finishOrder(order: Self.recipientViewModel.order)
            })
        }
        .snackBar(
          isShowing: $viewModel.showingErrorAlert,
          text: Text("An error occurred"),
          isError: true
        )
      }
    }
  }
  
  private var loadingPlaceholder: some View {
    ZStack {
      Color.backgroundColor
      ProgressView()
        .progressViewStyle(.circular)
        .tint(.black)
    }
  }
}
