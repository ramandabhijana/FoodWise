//
//  MerchantDetailsView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 01/03/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct MerchantDetailsView: View {
  @State private var tabBarOffset: CGFloat = 0
  @StateObject private var viewModel: MerchantDetailsViewModel
  @EnvironmentObject private var rootViewModel: RootViewModel
  @Environment(\.safeAreaInsets) private var safeAreaInsets
  
  init(viewModel: MerchantDetailsViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var body: some View {
    ScrollView(.vertical, showsIndicators: false) {
      LazyVStack(spacing: 16) {
        Image.merchantWave
          .resizable()
          .scaledToFill()
          .frame(height: 170)
          .opacity(0.75)
          .offset(y: 10)
          .background(Color.primaryColor)
          .clipped()
          
        VStack(alignment: .leading, spacing: 20) {
          Group {
            HStack(alignment: .bottom) {
              WebImage(url: viewModel.merchant?.logoUrl)
                .resizable()
                .placeholder {
                  Circle()
                    .fill(Color(uiColor: .lightGray).opacity(0.6))
                    .frame(width: 100, height: 100)
                    .overlay {
                      ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .tint(.white)
                    }
                }
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .padding(8)
                .shadow(radius: 10)
              
              Spacer()
              Button(action: { viewModel.goToChatView(currentUserId: rootViewModel.customer?.id) }) {
                HStack {
                  Image(systemName: "text.bubble.fill")
                  Text("Chat")
                }
                .foregroundColor(.white)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(
                  RoundedRectangle(cornerRadius: 10).fill(Color.accentColor)
                )
              }
              .overlay {
                NavigationLink(
                  isActive: $viewModel.showingChatView,
                  destination: { LazyView(ChatRoomView(userId: rootViewModel.customer!.id, otherUserType: kMerchantType, otherUserProfilePictureUrl: viewModel.merchant?.logoUrl, otherUserName: viewModel.merchant?.name, otherUserId: viewModel.merchant!.id)) },
                  label: EmptyView.init)
              }
            }
            .padding(.top, -50)
            
            VStack(alignment: .leading, spacing: 8) {
              Text(viewModel.merchant?.name ?? "Name of Merchant")
                .font(.title3)
                .fontWeight(.bold)
              HStack(alignment: .top, spacing: 16) {
                Image(systemName: "house")
                  .font(.subheadline)
                Text(viewModel.merchant?.storeType ?? "Store Type")
              }.font(.callout)
              HStack(alignment: .top, spacing: 16) {
                Image(systemName: "mappin.and.ellipse")
                  .font(.subheadline)
                VStack(alignment: .leading) {
                  Text(viewModel.merchant?.location.geocodedLocation ?? "Geocoded Location Address")
                  if (!(viewModel.merchant?.addressDetails.isEmpty ?? true)) {
                    Text(viewModel.merchant?.addressDetails ?? "Address details")
                      .font(.caption)
                  }
                }
              }.font(.callout)
            }
          }
          .padding(.horizontal)
          
          VStack(alignment: .leading) {
            Text("Browse Foods")
              .fontWeight(.bold)
            
            GeometryReader { proxy in
              HStack(spacing: 16) {
                TextField("Search...", text: .constant(""), prompt: nil)
                  .padding(.vertical, 5)
                  .padding(.horizontal)
                  .background(Color.white)
                  .cornerRadius(8)
                  .overlay {
                    RoundedRectangle(cornerRadius: 8)
                      .stroke(Color.init(uiColor: .darkGray), lineWidth: 1.5)
                  }
                
                Menu {
                  ForEach(
                    MerchantDetailsSortOptions.allCases,
                    id: \.rawValue
                  ) { option in
                    Button("\(option.rawValue)") {
                      viewModel.currentSortOption = option
                    }
                  }
                } label: {
                  RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.accentColor, lineWidth: 1.5)
                    .overlay(alignment: .leading) {
                      HStack {
                        Image(systemName: "arrow.up.arrow.down")
                          .font(.subheadline)
                        Text(viewModel.currentSortOption == .original
                             ? "Sort"
                             : viewModel.currentSortOption.rawValue)
                          .font(.caption)
                          .lineLimit(1)
                      }
                      .foregroundColor(.accentColor)
                      .padding(.vertical, 5)
                      .padding(.horizontal)
                    }
                }
                .frame(width: proxy.size.width * 0.35)
              }
              
            }
            .frame(height: 35)
            
            
            Divider()
          }
          .padding(.top, 16)
          .padding(.horizontal)
          .background(Color.backgroundColor)
          .offset(
            y: tabBarOffset < 7.0 ? -tabBarOffset + 7.0 : 0
          )
          .overlay(alignment: .top) {
            GeometryReader { proxy -> Color in
              let minY = proxy.frame(in: .global).minY
              DispatchQueue.main.async {
                tabBarOffset = minY - safeAreaInsets.top
              }
              return .clear
            }.frame(width: 0, height: 0)
          }
          .zIndex(1)
          
          Group {
            if viewModel.allFoods.isEmpty {
              VStack {
                Image("empty_list")
                  .resizable()
                  .scaledToFit()
                  .frame(width: 100, height: 100)
                Text("No results can be shown").font(.subheadline)
              }
              .frame(maxWidth: .infinity, alignment: .center)
              .padding(.top, 20)
            } else {
              LazyVGrid(
                columns: Array(repeating: .init(spacing: 20), count: 2),
                spacing: 20
              ) {
                ForEach(
                  viewModel.allFoods,
                  content: buildFoodCell(food:)
                )
                  .redacted(reason: viewModel.loading ? .placeholder : [])
              }
            }
          }
          .padding(.horizontal)
          
          /*
          VStack(alignment: .leading, spacing: 18) {
            
            // First tweet
            TweetView(tweet: "Introducing the new iPad Pro with M1",
                      tweetImage: "ipad")
            Divider()
            
            ForEach(1...20, id: \.self) { _ in
              TweetView(tweet: "Tweet by Apple will be shown here")
              Divider()
            }
          }
          */
        }
//        .padding(.horizontal)
      }
      
    }
    .redacted(reason: viewModel.loading ? .placeholder : [])
    .navigationBarTitleDisplayMode(.inline)
    .ignoresSafeArea(.all, edges: .top)
    .background(Color.backgroundColor)
    .onAppear {
      setNavigationBarColor(withStandardColor: .backgroundColor, andScrollEdgeColor: .primaryColor)
      NotificationCenter.default.post(
        name: .tabBarHiddenNotification,
        object: nil)
    }
//    .onAppear {
//      NotificationCenter.default.post(
//        name: .tabBarHiddenNotification,
//        object: nil)
//    }
  }
  
  private func buildFoodCell(food: Food) -> some View {
    FoodCell1(
      food: food,
      isLoading: viewModel.loading,
      buildDestination: FoodDetailsView(
        viewModel: .init(
          food: food,
          customerId: rootViewModel.customer?.id,
          foodRepository: viewModel.foodRepository
        )
      )
    )
  }
  
  private struct FoodsListView: View {
    @ObservedObject var viewModel: MerchantDetailsViewModel
    @EnvironmentObject private var rootViewModel: RootViewModel
    
    var body: some View {
      if viewModel.allFoods.isEmpty {
        VStack {
          Image("empty_list")
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
          Text("No results can be shown").font(.subheadline)
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
      } else {
        LazyVGrid(
          columns: Array(repeating: .init(spacing: 20), count: 2),
          spacing: 20
        ) {
          ForEach(
            viewModel.allFoods,
            content: buildFoodCell(food:)
          )
            .redacted(reason: viewModel.loading ? .placeholder : [])
        }
      }
    }
    
    private func buildFoodCell(food: Food) -> some View {
      FoodCell1(
        food: food,
        isLoading: viewModel.loading,
        buildDestination: FoodDetailsView(
          viewModel: .init(
            food: food,
            customerId: rootViewModel.customer?.id,
            foodRepository: viewModel.foodRepository
          )
        )
      )
    }
  }
  
  
  
}

//struct MerchantDetailsView_Previews: PreviewProvider {
//  static var previews: some View {
//    MerchantDetailsView()
//  }
//}
