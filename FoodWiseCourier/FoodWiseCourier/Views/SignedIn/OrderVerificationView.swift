//
//  OrderVerificationView.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 18/04/22.
//

import SwiftUI

struct OrderVerificationView: View {
  @StateObject private var viewModel: OrderVerificationViewModel
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
  
  init(viewModel: OrderVerificationViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
    Self.recipientViewModel = LegitimateRecipientViewModel(
      isPaid: viewModel.isPaid,
      isUsingDelivery: true,
      lineItems: viewModel.makeLineItems(),
      priceSection: viewModel.makePriceSection())
  }
  
//  init() {
//  }
  
  var body: some View {
    NavigationView {
      ZStack {
        QRScanViewController.View(viewModel: viewModel)
//        QRScanViewController.View<OrderVerificationViewModel>()
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
          Button {
            dismiss()
          } label: {
            Image(systemName: "xmark")
              .font(.footnote.bold())
              .foregroundColor(.black)
              .padding(5)
              .background(Circle().fill(.thickMaterial))
          }
        }
        ToolbarItem(placement: .principal) {
          Text("Order Verification")
            .font(.title3.bold())
            .foregroundColor(.white)
        }
      }
      .onAppear {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
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
          isPaid: viewModel.isPaid,
          isUsingDelivery: true,
          lineItems: viewModel.makeLineItems(),
          priceSection: viewModel.makePriceSection())
        viewModel.showingOrderVerified = true
      }
      .sheet(isPresented: $viewModel.showingOrderVerified) {
        LegitimateRecipientView(
          viewModel: Self.recipientViewModel,
          onTapRetry: {
            viewModel.dismissVerifiedView()
            NotificationCenter.default.post(
              name: .qrScannerCaptureSessionShouldStartRunning,
              object: nil)
          },
          onTapFinish: {
            NotificationCenter.default.post(
              name: OrderVerificationViewModel.didFinishVerificationNotification,
              object: nil)
            dismiss()
          })
      }
    }
    
    
  }
  
  
}


