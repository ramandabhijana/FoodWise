//
//  ReceiptVerificationView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 07/05/22.
//

import SwiftUI

struct ReceiptVerificationView: View {
  @EnvironmentObject private var rootViewModel: RootViewModel
  @StateObject private var viewModel: ReceiptVerificationViewModel
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
  
  init(viewModel: ReceiptVerificationViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
    Self.recipientViewModel = LegitimateRecipientViewModel(
      lineItems: viewModel.makeLineItems(),
      priceSection: viewModel.makePriceSection())
  }
  
//  init() {
//  }
  
  var body: some View {
    NavigationView {
      ZStack {
        QRScanViewController.View(viewModel: viewModel)
          .ignoresSafeArea()
        
        scanLine
          .offset(y: scanLineOffset)
          .animation(
            .easeInOut(duration: 1.8).repeatForever(autoreverses: false),
            value: scanLineOffset
          )
        
        // if merchant & customer
        /*
        HStack(spacing: 16) {
          ProgressView()
            .progressViewStyle(.circular)
          Text("Evaluating Code")
        }
        .padding()
        .background(.ultraThickMaterial)
        .cornerRadius(10)
        */
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
      .onReceive(viewModel.qrCodeValidPublisher) { _ in
        Self.recipientViewModel = LegitimateRecipientViewModel(
          lineItems: viewModel.makeLineItems(),
          priceSection: viewModel.makePriceSection())
        viewModel.showingReceiptVerified = true
      }
      .sheet(isPresented: $viewModel.showingReceiptVerified) {
        LegitimateRecipientView(
          viewModel: Self.recipientViewModel,
          onTapRetry: viewModel.dismissVerifiedView,
          onTapFinish: {
            NotificationCenter.default.post(
              name: ReceiptVerificationViewModel.didFinishVerificationNotification,
              object: nil)
            rootViewModel.incrementFoodSharedCount()
            dismiss()
          })
      }
    }
    
    
  }
  
  
}
