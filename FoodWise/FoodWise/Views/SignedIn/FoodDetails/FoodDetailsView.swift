//
//  FoodDetailsView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 17/11/21.
//

import SwiftUI
import SDWebImageSwiftUI
import SwiftUIPullToRefresh

struct FoodDetailsView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel: FoodDetailsViewModel
  
  @State private var navigationBarBackgroundColor = Color.clear
  @State private var showTitle = false
  @State private var showsPhotoZoomView = false
  @State private var navigationController: UINavigationController? = nil
  @State private var tabBar: UITabBar? = nil
  
  private var contentWidth: CGFloat = UIScreen.main.bounds.width - 30
  
  // To be called when the view is dismissed and the food is no longer a favorite
  private var onDismiss: ((Food) -> Void)?
  
  private static var tappedPhotoUrl: URL?
  
  
  init(
    viewModel: FoodDetailsViewModel,
    onDismiss: ((Food) -> Void)? = nil
  ) {
    print("initializing FoodDetailsview")
    _viewModel = StateObject(wrappedValue: viewModel)
    self.onDismiss = onDismiss
  }
  
  
  
  var body: some View {
    ZStack(alignment: .top) {
      Color.backgroundColor
      
      RefreshableScrollView(showsIndicators: false, onRefresh: { done in
        viewModel.fetchFood { done() }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//          done()
//        }
      }, progress: { state in
        VStack {
          switch state {
          case .waiting:
            Text("Pull down")
          case .primed:
            Text("Release to refresh")
          case .loading:
            ProgressView()
              .tint(.black)
              .padding(.top, 40)
          }
        }
        .font(.caption)
        .frame(maxWidth: .infinity, maxHeight: 68)
        .background(Color.backgroundColor)
      }) {
        LazyVStack(spacing: 18) {
          GeometryReader { proxy -> AnyView in
            let minY = proxy.frame(in: .global).minY
            return AnyView(
              TabView {
                ForEach(viewModel.food.imagesUrl, id: \.self) { url in
                  WebImage(url: url)
                    .resizable()
                    .onChange(of: minY) { value in
                      DispatchQueue.main.async {
                        if abs(value) > (.headerImageHeight * 0.76) {
                          withAnimation { navigationBarBackgroundColor = Color.primaryColor }
                        } else {
                          withAnimation { navigationBarBackgroundColor = .clear }
                        }
                      }
                    }
                    .onTapGesture {
                      Self.tappedPhotoUrl = url
                      showsPhotoZoomView.toggle()
                    }
                }
              }
              .tabViewStyle(.page)
            )
          }.frame(height: .headerImageHeight)
          
          VStack(spacing: 25) {
            GeometryReader { proxy -> AnyView in
              let minY = proxy.frame(in: .global).minY
              return AnyView(
                HStack(alignment: .top,spacing: 15) {
                  Text(viewModel.food.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                  
                  Spacer()
                  VStack(alignment: .trailing) {
                    Text(viewModel.food.priceString)
                      .font(.title2)
                      .fontWeight(.bold)
                    Text("\(viewModel.food.discountRateString) OFF")
                      .font(.callout)
                      .foregroundColor(.red)
                    Text("was " + viewModel.food.retailPriceString)
                      .font(.callout)
                      .foregroundColor(.secondary)
                  }
                }
                .onChange(of: minY) { value in
                  DispatchQueue.main.async {
                    let viewNotCoveredByNavigationBar = value > (.headerImageHeight * 0.17)
                    if viewNotCoveredByNavigationBar {
                      if showTitle {
                        withAnimation { showTitle = false }
                      }
                    } else {
                      if !showTitle {
                        withAnimation(.easeOut) { showTitle = true }
                      }
                    }
                  }
                }
              )
            }
            .frame(
              width: contentWidth,
              height: 65
            )
            divider
              
            HStack(spacing: 20) {
              WebImage(url: viewModel.merchant?.logoUrl)
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
              VStack(alignment: .leading) {
                Text(viewModel.merchant?.name ?? "Merchant's name")
                Text(viewModel.merchant?.storeType ?? "Store Type")
                  .font(.footnote)
              }
            }
            .frame(width: contentWidth, alignment: .leading)
            divider
            
            VStack(alignment: .leading, spacing: 10) {
              Text("Food's Details")
                .bold()
                .padding(.bottom)
              HStack(alignment: .top) {
                Text("Stock Left")
                  .fontWeight(.light)
                Spacer()
                Text("\(viewModel.food.stock)")
                  .frame(width: contentWidth * 0.58, alignment: .leading)
              }
              
              HStack(alignment: .top) {
                Text("Category")
                  .fontWeight(.light)
                Spacer()
                Text(viewModel.food.categoriesName)
                  .frame(width: contentWidth * 0.58, alignment: .leading)
              }
              
              Text(viewModel.food.description.isEmpty
                   ? "No Description"
                   : viewModel.food.description)
                .font(.callout)
                .padding(.top, 10)
            }
            .frame(width: contentWidth)
            
            divider
            
            VStack(alignment: .leading, spacing: 10) {
              Text("Rating and Reviews")
                .bold()
                .padding(.bottom)
              Text("The food has never received a review")
                .font(.callout)
              
              /*
              VStack(alignment: .leading, spacing: 0) {
                Text("4.5 ★★★★★").font(.title3)
                Text("(16 Reviews)").fontWeight(.light)
              }
              .padding(.vertical, 10)
              
              VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 0) {
                  HStack {
                    Text("★★★★★")
                    Spacer()
                    Text("13 Sep 2021")
                  }
                  Text("by Mathijs").foregroundColor(.secondary)
                }
                .font(.callout)
                Text("Delicious, Nice")
                Divider()
                
                VStack(alignment: .leading, spacing: 0) {
                  HStack {
                    Text("★★★★★")
                    Spacer()
                    Text("13 Sep 2021")
                  }
                  Text("by Mathijs").foregroundColor(.secondary)
                }
                .font(.callout)
                Text("Delicious, Nice")
              }
              .padding(.vertical, 5)
              .padding(.bottom, 10)
              
              Button(
                action: {},
                label: {
                  Text("See all")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                })
              */
              
            }
            .frame(width: contentWidth, alignment: .leading)
            
//            Rectangle()
//              .fill(Color(.systemFill))
//              .frame(height: 10)
            
//            SimilarFoods()
//              .padding(.horizontal)
          }
//          .frame(width: contentWidth)
        }
        .padding(.bottom, 140)
        .redacted(reason: viewModel.merchant == nil ? .placeholder : [])
      }
      
      .overlay(alignment: .top) {
        NavigationBarView(
          width: UIScreen.main.bounds.width - 30,
          title: viewModel.food.name,
          subtitle: viewModel.food.priceString,
          showTitle: showTitle,
          backgroundColor: navigationBarBackgroundColor,
          onTapBackButton: onTapBackButton,
          favoriteButtonLabel: favoriteButtonLabel,
          onTapFavoriteButton: onTapFavoriteButton
        ).clipped()
      }
      .overlay(alignment: .bottom) {
        ZStack {
          Rectangle()
            .fill(Color.secondaryColor)
            .frame(height: 45)
            .shadow(
              color: .black,
              radius: 15,
              y: -5)
          GeometryReader { proxy in
            HStack(alignment: .center) {
              Button(
                action: {},
                label: {
                  RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(Color.accentColor, lineWidth: 3)
                    .overlay(
                      Image(systemName: "text.bubble.fill")
                        .foregroundColor(.accentColor)
                        .font(.title2)
                    )
                    .background(
                      RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                    )
                })
              Button(
                action: {},
                label: {
                  RoundedRectangle(cornerRadius: 10)
                    .fill(Color.accentColor)
                    .frame(width: proxy.size.width * 0.78)
                    .overlay {
                      HStack {
                        Image(systemName: "bag.fill.badge.plus")
                        Text("Add to Bag")
                          .bold()
                      }
                      .foregroundColor(.white)
                    }
                })
            }
            .frame(
              width: UIScreen.main.bounds.width - 30,
              height: 44
            )
          }
          .frame(height: 48)
          .padding(.top, 10)
          .padding(.horizontal)
          .padding(.bottom, 34)
  //        .padding(.bottom, .safeAreaInsetsBottom)
          .background(Color.secondaryColor)
        }
      }
      .sheet(isPresented: $showsPhotoZoomView) {
        PhotoZoomViewController.View(url: Self.tappedPhotoUrl)
          .ignoresSafeArea()
          .overlay(alignment: .topTrailing) {
            Button("\(Image(systemName: "xmark.circle.fill"))") {
              showsPhotoZoomView = false
            }
            .foregroundColor(.white)
            .padding()
          }
      }
      
      
      
      
    }
    .ignoresSafeArea()
    .onDisappear {
      navigationController?.isNavigationBarHidden = false
      tabBar?.isHidden = false
    }
    .snackBar(
      isShowing: $viewModel.onUpdateFavoriteList.shows,
      text: Text(viewModel.onUpdateFavoriteList.message),
      shouldNotifyNotificationFeedbackOccurred: true
    )
    .introspectNavigationController { controller in
      controller.isNavigationBarHidden = true
    }
    .introspectTabBarController { controller in
      tabBar = controller.tabBar
      controller.tabBar.isHidden = true
    }
  }
  
  private var divider: some View {
    Rectangle()
      .fill(Color(.systemFill))
      .frame(height: 10)
  }
  
  private func onTapBackButton() {
    if !viewModel.favorited, let onDismiss = onDismiss {
      onDismiss(viewModel.food)
    }
    dismiss()
  }
  
  private func favoriteButtonLabel() -> some View {
    Group {
      if viewModel.favorited {
        Image(systemName: "heart.fill")
          .foregroundColor(.pink)
      } else {
        Image(systemName: "heart")
          .foregroundColor(.init(uiColor: .darkGray))
      }
    }.font(.title3)
  }
  
  private func onTapFavoriteButton() {
    guard !viewModel.loading else { return }
    if viewModel.favorited {
      viewModel.removeFromFavorite()
    } else {
      viewModel.addToFavorite()
    }
  }
  
  
}

struct FoodDetailsView_Previews: PreviewProvider {
  static var previews: some View {
    FoodDetailsView(viewModel: .init(food: .sampleData.first!, foodRepository: .init()))
  }
}

private extension CGFloat {
  static let headerImageHeight = UIScreen.main.bounds.height / 2.2
}
