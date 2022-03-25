//
//  SharedFoodsView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 13/03/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct SharedFoodsView: View {
  @EnvironmentObject private var rootViewModel: RootViewModel
  @StateObject private var viewModel: SharedFoodsViewModel
  static private var donateViewModel: DonateFoodViewModel!
  
  init(viewModel: SharedFoodsViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var body: some View {
    NavigationView {
      ScrollView {
        if viewModel.donatedFoods.isEmpty {
          VStack {
            Spacer()
            Image("empty_list")
              .resizable()
              .frame(
                width: UIScreen.main.bounds.width * 0.25,
                height: UIScreen.main.bounds.width * 0.25
              )
            Text("No results")
            Spacer()
          }
//          .frame(maxWidth: .infinity)
          .frame(
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.height * 0.65)
        } else {
          LazyVGrid(
            columns: [.init(.adaptive(minimum: 130), spacing: 22)],
            spacing: 22
          ) {
            ForEach(viewModel.donatedFoods, id: \.self) { donation in
              DonationCell(
                model: donation,
                loading: viewModel.loading,
                buildDestination: DonationDetailsView(
                  viewModel: .init(donationModel: donation,
                                   currentCustomer: rootViewModel.customer!,
                                   repository: viewModel.repository))
              )
            }
          }
          .padding()
          .padding(.bottom, 110)
        }
      }
      .onAppear {
        if viewModel.allDonatedFoods == nil {
          viewModel.loadDonatedFoods()
        }
        setNavigationBarColor(
          withStandardColor: .backgroundColor,
          andScrollEdgeColor: .backgroundColor)
        NotificationCenter.default.post(name: .tabBarShownNotification, object: nil)
        NotificationCenter.default.post(name: .tabBarChangeBackgroundToSecondaryColorNotification, object: nil)
      }
      .navigationBarTitleDisplayMode(.inline)
      .background(Color.backgroundColor)
      .overlay(alignment: .bottom) {
        ZStack(alignment: .bottom) {
          LinearGradient(
            colors: [
              .backgroundColor.opacity(0.2),
              .backgroundColor.opacity(0.8),
              .backgroundColor
            ],
            startPoint: .top,
            endPoint: .bottom
          ).frame(height: 100)
            
          Button(action: {
            Self.donateViewModel = DonateFoodViewModel(repository: viewModel.repository)
            viewModel.listenNewDonationPublisher(Self.donateViewModel.newDonationPublisher)
            viewModel.showingDonateView = true
          }) {
            RoundedRectangle(cornerRadius: 22)
              .frame(
                width: UIScreen.main.bounds.width * 0.5,
                height: 44
              )
              .shadow(radius: 5)
              .overlay {
                HStack {
                  Image(systemName: "tray.and.arrow.up.fill")
                  Text("Donate").bold()
                }
                .foregroundColor(.white)
              }
          }
          .padding(.bottom)
//          .overlay {
//            NavigationLink(
//              isActive: $viewModel.showingDonateView,
//              destination: {
//                LazyView(DonateFoodView(
//                  viewModel: Self.donateViewModel,
//                  locationViewModel: SelectLocationViewModel())
//                )
//              },
//              label: EmptyView.init)
//          }
        }
      }
      .fullScreenCover(isPresented: $viewModel.showingDonateView) {
        LazyView(DonateFoodView(
          viewModel: Self.donateViewModel,
          locationViewModel: SelectLocationViewModel())
        )
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Menu {
            ForEach(SharedFoodKind.allCases, id: \.rawValue) { kind in
              Button("\(kind.rawValue)") {
                viewModel.currentSelectedKind = kind
              }
            }
          } label: {
            HStack {
              Text("\(viewModel.currentSelectedKind.rawValue)")
                .font(.title)
                .fontWeight(.bold)
              Image(systemName: "chevron.down")
                .font(.caption)
            }
            .foregroundColor(.init(uiColor: .darkGray))
          }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          HStack {
            NavigationLink(destination: {
              LazyView(IncomingRequestsView(
                viewModel: .init(repository: viewModel.repository,
                                 userId: rootViewModel.customer!.id)
              ))
            }, label: {
              Image(systemName: "envelope.fill")
            })
            Button(action: { }) {
              Image(systemName: "archivebox.fill")
            }
            
          }
          .foregroundColor(.init(uiColor: .darkGray))
        }
      }
      
    }
  }
}

private extension SharedFoodsView {
  struct DonationCell<Destination: View>: View {
    var model: DonationModel
    var loading: Bool
    let buildDestination: () -> Destination
    
    init(
      model: DonationModel,
      loading: Bool,
      buildDestination: @autoclosure @escaping () -> Destination
    ) {
      self.model = model
      self.loading = loading
      self.buildDestination = buildDestination
    }
    
    var body: some View {
      NavigationLink(
        destination: LazyView(buildDestination()),
        label: makeLabel
      ).disabled(loading)
    }
    
    private func makeLabel() -> some View {
      ZStack(alignment: .top) {
        RoundedRectangle(cornerRadius: 10)
          .fill(Color.white)
          .frame(height: 270)
          .shadow(radius: 2)
        
        GeometryReader { proxy in
          VStack(alignment: .leading, spacing: 8) {
            WebImage(url: model.donation.pictureUrl)
              .resizable()
              .scaledToFill()
              .frame(
                width: proxy.size.width,
                height: proxy.size.height * 0.6
              )
              .clipped()
              .cornerRadius(10)
            
            Text(model.donation.foodName)
              .font(.subheadline)
              .bold()
              .lineLimit(1)
              .foregroundColor(.black)
            HStack(alignment: .top) {
              WebImage(url: model.donorUser.profileImageUrl)
                .resizable()
                .frame(width: 25, height: 25)
                .clipShape(Circle())
              VStack(alignment: .leading, spacing: 0) {
                Text("Shared by")
                  .font(.caption2)
                  .foregroundColor(.secondary)
                Text(model.donorUser.fullName)
                  .font(.caption)
                  .lineLimit(2)
                  .foregroundColor(.black)
              }
              
            }
            Spacer()
            Text("\(Image(systemName: "location.fill")) \(model.donation.pickupLocation.geocodedLocation)")
              .lineLimit(1)
              .foregroundColor(.init(uiColor: .darkGray))
              .font(.caption2)
          }
        }
        
        .padding(10)
      }
      
      .redacted(reason: loading ? .placeholder : [])
    }
  }
}
