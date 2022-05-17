//
//  AdoptionRequestDetailView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 16/03/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct AdoptionRequestDetailView: View {
  @StateObject private var viewModel: AdoptionRequestDetailViewModel
  @EnvironmentObject private var rootViewModel: RootViewModel
  @Environment(\.dismiss) private var dismiss
  
  init(viewModel: AdoptionRequestDetailViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var body: some View {
    VStack(spacing: 0) {
      Rectangle()
        .fill(Color.primaryColor)
        .frame(height: 80)
        .overlay(alignment: .leading) {
          HStack(alignment: .center, spacing: 12) {
            WebImage(url: viewModel.donation.pictureUrl)
              .resizable()
              .frame(width: 50, height: 50)
              .cornerRadius(10)
            VStack(alignment: .leading, spacing: 5) {
              Text(viewModel.donation.foodName)
              Text("\(viewModel.donation.adoptionRequests.count) Adoption Requests")
                .font(.subheadline)
                .fontWeight(.bold)
            }
          }
          .padding()
        }
      
      ScrollView {
        VStack {
          ForEach(viewModel.donation.adoptionRequests) { request in
            RequestCell(viewModel: viewModel,
                        request: request,
                        currentUser: rootViewModel.customer!)
          }
        }
        .padding(.top)
      }
    }
    .background(Color.backgroundColor)
    .toolbar {
      ToolbarItem(placement: .principal) {
        Text("Long press on a request to accept")
          .font(.subheadline)
      }
    }
    .snackBar(
      isShowing: $viewModel.showingAcceptingSnackbar,
      text: Text("Accepting request...")
    )
    .snackBar(
      isShowing: $viewModel.showingErrorSnackbar,
      text: Text("Something went wrong"),
      isError: true
    )
    .onReceive(viewModel.donationPublisher) { _ in
      dismiss()
    }
    .onAppear {
      setNavigationBarColor(withStandardColor: .primaryColor,
                            andScrollEdgeColor: .primaryColor)
    }
  }
}

private extension AdoptionRequestDetailView {
  struct RequestCell: View {
    @ObservedObject var viewModel: AdoptionRequestDetailViewModel
    @State private var showingChatView = false
    var request: AdoptionRequest
    var currentUser: Customer
    
    var body: some View {
      VStack(alignment: .leading, spacing: 8) {
        Text("Sent on \(viewModel.cellDateFormatter.string(from: request.date.dateValue()))")
          .font(.footnote)
          .bold()
          .foregroundColor(.secondary)
        HStack(spacing: 8) {
          WebImage(url: request.requesterCustomer.profileImageUrl)
            .resizable()
            .frame(width: 35, height: 35)
            .clipShape(Circle())
          Text(request.requesterCustomer.fullName)
            .lineLimit(1)
          Spacer()
          Button(action: { showingChatView = true }) {
            Text("Chat")
              .font(.subheadline)
              .padding(.horizontal)
              .padding(.vertical, 5)
              .overlay {
                RoundedRectangle(cornerRadius: 4)
                  .strokeBorder(lineWidth: 2)
              }
          }
          .overlay {
            NavigationLink(
              isActive: $showingChatView,
              destination: {
                LazyView(ChatRoomView(
                  userId: currentUser.id,
                  otherUserType: kCustomerType,
                  otherUserProfilePictureUrl: request.requesterCustomer.profileImageUrl,
                  otherUserName: request.requesterCustomer.fullName,
                  otherUserId: request.requesterCustomer.id))
              },
              label: EmptyView.init)
          }
        }
        .padding(.top, 5)
        Divider()
          .padding(.vertical, 3)
        
        VStack(alignment: .leading, spacing: 10) {
          HStack {
            Text("Message")
              .font(.footnote)
              .bold()
            Spacer()
            Button(action: {
              guard viewModel.showedMessageRequest != request else {
                viewModel.showedMessageRequest = nil
                return
              }
              viewModel.showedMessageRequest = request
            }) {
              Image(systemName: "chevron.right")
                .rotationEffect(Angle(degrees: viewModel.showedMessageRequest == request ? 90 : 0))
            }
          }
          
          if viewModel.showedMessageRequest == request {
            Text(request.messageForDonor)
              .font(.footnote)
          }
        }
        
      }
      .padding()
      .background(
        RoundedRectangle(cornerRadius: 0)
          .fill(Color.white)
          .shadow(radius: 2)
      )
      .animation(.easeOut, value: viewModel.showedMessageRequest == request)
      .contextMenu {
        Button(
          action: { viewModel.showAcceptAlert(withRequest: request) },
          label: { Text("Accept Request") }
        )
      }
      .padding(.vertical, 5)
      
      .alert(
        "Accept request from \"\(viewModel.toBeAcceptedRequest?.requesterCustomer.fullName ?? "")\" ?",
        isPresented: $viewModel.showingAcceptAlert
      ) {
        Group {
          Button("Cancel") { }
          Button("Yes") {
            viewModel.acceptRequest(currentUser: currentUser)
          }
        }
      }
    }
    
    
  }
}
