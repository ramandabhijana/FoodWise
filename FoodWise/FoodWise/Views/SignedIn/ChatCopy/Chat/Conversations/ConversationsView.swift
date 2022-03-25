//
//  ConversationsView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 03/03/22.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseFirestore
import Combine

struct ConversationsView: View {
  @EnvironmentObject var mainViewModel: MainViewModel
  @StateObject var viewModel: ConversationsViewModel
  
  init() {
    let viewModel = ConversationsViewModel()
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var body: some View {
    Group {
      ZStack {
        if !viewModel.conversations.isEmpty {
          List {
            ForEach(viewModel.conversations.indices) { index in
              CellView(
                repository: {
                  switch viewModel.conversations[index].conversation.otherUserType {
                  case kCustomerType:
                    return CustomerRepository()
                  case kMerchantType:
                    return MerchantRepository()
                  case kCourierType:
                    return CustomerRepository() // Temporary
                  default:
                    fatalError("Unresolved type")
                  }
                }(),
                conversation: viewModel.conversations[index].conversation,
                userId: mainViewModel.merchant.id,
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
    .onAppear {
      viewModel.listenForConversations(for: mainViewModel.merchant.id)
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
            HStack {
              WebImage(url: model.userDetail?.profilePictureUrl)
                .resizable()
                .frame(width: 30, height: 30)
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
  @State private var listInitialized = false
  
  private(set) var repository: ChatRepository
  private var listenerRegistration: ListenerRegistration?
  
  init(repository: ChatRepository = ChatRepository()) {
    self.repository = repository
  }
  
  deinit {
    listenerRegistration?.remove()
  }
  
  func listenForConversations(for userId: String) {
    guard listInitialized == false else { return }
    listInitialized = true
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

private struct ConversationsModel: Identifiable {
  var userDetail: (name: String, profilePictureUrl: URL?)? = nil
  var conversation: Conversation
  var id: String { conversation.id }
}

//struct ConversationsView_Previews: PreviewProvider {
//  static var previews: some View {
//    ConversationsView()
//  }
//}
