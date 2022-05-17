//
//  IncomingRequestsView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 16/03/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct IncomingRequestsView: View {
  @StateObject private var viewModel: IncomingRequestsViewModel
  
  init(viewModel: IncomingRequestsViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var body: some View {
    List {
      ForEach(viewModel.donations) { donation in
        DonationCell(
          donation: donation,
          loading: viewModel.isLoading,
          buildDestination: AdoptionRequestDetailView(
            viewModel: {
              let viewModel = AdoptionRequestDetailViewModel(
                donation: donation,
                repository: viewModel.repository)
              self.viewModel.listenDonationPublisher(viewModel.donationPublisher)
              return viewModel
            }()
          )
        )
        .padding(.vertical, 8)
      }
      .listRowBackground(Color.clear)
      .listRowSeparator(.hidden)
    }
    .listStyle(.plain)
    .background(Color.backgroundColor)
    .navigationTitle("Incoming Requests")
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      setNavigationBarColor(withStandardColor: .primaryColor, andScrollEdgeColor: .primaryColor)
      NotificationCenter.default.post(name: .tabBarHiddenNotification, object: nil)
    }
    .overlay {
      if viewModel.donations.isEmpty {
        VStack {
          Image("empty_file")
            .resizable()
            .frame(
              width: UIScreen.main.bounds.width * 0.25,
              height: UIScreen.main.bounds.width * 0.25
            )
          Text("You have no incoming requests")
        }
      }
    }
    
  }
  
}

private extension IncomingRequestsView {
  struct DonationCell<Destination: View>: View {
    var donation: Donation
    var loading: Bool
    let buildDestination: () -> Destination
    
    init(
      donation: Donation,
      loading: Bool,
      buildDestination: @autoclosure @escaping () -> Destination
    ) {
      self.donation = donation
      self.loading = loading
      self.buildDestination = buildDestination
    }
    
    var body: some View {
      makeLabel()
    }
    
    private func makeLabel() -> some View {
      ZStack(alignment: .leading) {
        RoundedRectangle(cornerRadius: 8)
          .fill(Color.white)
          .shadow(radius: 2)
        HStack(alignment: .bottom, spacing: 12) {
          WebImage(url: donation.pictureUrl)
            .resizable()
            .frame(width: 80, height: 80)
            .cornerRadius(10)
          VStack(alignment: .leading, spacing: 5) {
            Text(donation.foodName)
            Text("\(donation.adoptionRequests.count) Requests")
              .font(.subheadline)
              .fontWeight(.bold)
              .padding(.bottom, 8)
            Text("Donated on \(IncomingRequestsViewModel.cellDateFormatter.string(from: donation.date.dateValue()))")
              .font(.footnote)
              .bold()
              .foregroundColor(.secondary)
          }
        }
        .padding()
        
        NavigationLink(
          destination: LazyView(buildDestination()),
          label: { EmptyView() }
        ).frame(width: 0).opacity(0.0).disabled(loading)
        
      }
      .frame(height: 100)
      .redacted(reason: loading ? .placeholder : [])
    }
  }
}
