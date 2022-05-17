//
//  ConversationsView.swift
//  FoodWiseCourier
//
//  Created by Abhijana Agung Ramanda on 15/05/22.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseFirestore
import Combine

struct ConversationsView: View {
  @EnvironmentObject var rootViewModel: RootViewModel
  @StateObject var viewModel: ConversationsViewModel
  
  init(viewModel: ConversationsViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
    viewModel.listenForConversations()
  }
  
  var body: some View {
    Group {
      ZStack {
        if !viewModel.conversations.isEmpty {
          List {
            ForEach(Array(viewModel.conversations.enumerated()), id: \.element) { (index, conversation) in
              CellView(
                repository: {
                  switch conversation.conversation.otherUserType {
                  case kCustomerType:
                    return CustomerRepository()
                  case kMerchantType:
                    return MerchantRepository()
                  case kCourierType:
                    return CourierRepository()
                  default:
                    fatalError("Unresolved type")
                  }
                }(),
                conversation: conversation.conversation,
                userId: rootViewModel.customer!.id,
                model: $viewModel.conversations[index])
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
          }
          .listStyle(.plain)
          .padding(.vertical)
        } else {
          VStack {
            Spacer()
            Image("empty_message")
              .resizable()
              .frame(width: UIScreen.main.bounds.width * 0.25, height: UIScreen.main.bounds.width * 0.25)
            Text("You have no conversation")
            Spacer()
          }
          .frame(maxWidth: .infinity)
          
          
        }
      }
    }
    .background(Color("BackgroundColor"))
    .navigationTitle("Chat")
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      setNavigationBarColor(withStandardColor: .primaryColor, andScrollEdgeColor: .primaryColor)
      NotificationCenter.default.post(name: .tabBarHiddenNotification, object: nil)
    }
  }
}

private extension ConversationsView {
  struct CellView: View {
    let repository: ProfileUrlNameFetchableRepository
    let conversation: Conversation
    let userId: String
    @Binding var model: ConversationsModel
    @State private var subscription: AnyCancellable?
    
    var body: some View {
      NavigationLink {
        LazyView(ChatRoomView(
          userId: userId,
          otherUserType: conversation.otherUserType,
          otherUserProfilePictureUrl: model.userDetail?.profilePictureUrl,
          otherUserName: model.userDetail?.name,
          otherUserId: conversation.otherUserId,
          chatRoomId: conversation.chatRoomId))
      } label: {
        RoundedRectangle(cornerRadius: 8)
          .fill(Color.white)
          .frame(height: 60)
          .shadow(radius: 2)
          .overlay(alignment: .leading) {
            HStack(spacing: 16) {
              WebImage(url: model.userDetail?.profilePictureUrl)
                .resizable()
                .frame(width: 35, height: 35)
                .clipShape(Circle())
              VStack(alignment: .leading) {
                Text(model.userDetail?.name ?? "Name of user")
                  .font(.subheadline)
                  .foregroundColor(.black)
                Text(model.conversation.latestMessage.text)
                  .font(.caption)
                  .foregroundColor(.secondary)
              }
              .lineLimit(1)
            }
            .padding()
            .redacted(reason: model.userDetail == nil ? .placeholder : [])
          }
      }
      .onAppear {
        if model.userDetail == nil {
          subscription = repository.fetchNameAndProfilePictureUrl(ofUserWithId: model.conversation.otherUserId)
            .sink(receiveCompletion: { completion in
              
            }, receiveValue: { value in
              self.model.userDetail = value
              print("Received value: \(value)")
            })
        } else {
          subscription = nil
        }
      }
    }
  }
}

class ConversationsViewModel: ObservableObject {
  @Published fileprivate var conversations: [ConversationsModel] = []

  private(set) var repository: ChatRepository
  private let userId: String
  private var listenerRegistration: ListenerRegistration?
  
  init(userId: String, repository: ChatRepository = ChatRepository()) {
    self.userId = userId
    self.repository = repository
  }
  
  deinit {
    listenerRegistration?.remove()
  }
  
  func listenForConversations() {
    listenerRegistration = repository.getConversations(forUserWithId: userId, completion: { [weak self] conversations in
      guard let self = self else { return }
      var newConversations = self.conversations
      for conversation in conversations.all {
        if let index = newConversations.firstIndex(where: { $0.id == conversation.id }) {
          newConversations[index].conversation.latestMessage = conversation.latestMessage
        } else {
          newConversations.append(ConversationsModel(conversation: conversation))
        }
      }
      self.conversations = newConversations.sorted(by: { $0.conversation.latestMessage.date.dateValue() > $1.conversation.latestMessage.date.dateValue() })
    })
  }
}

private struct ConversationsModel: Identifiable, Hashable {
  static func == (lhs: ConversationsModel, rhs: ConversationsModel) -> Bool {
    lhs.id == rhs.id
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  var userDetail: (name: String, profilePictureUrl: URL?)? = nil
  var conversation: Conversation
  var id: String { conversation.id }
}
