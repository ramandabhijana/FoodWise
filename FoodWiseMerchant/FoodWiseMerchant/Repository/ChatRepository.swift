//
//  ChatRepository.swift
//  FoodWiseMerchant
//
//  Created by Abhijana Agung Ramanda on 06/03/22.
//

import Foundation
import Combine
import FirebaseFirestore

final class ChatRepository {
  private let db = Firestore.firestore()
  
  private let conversationsPath = "conversations"
  private let chatRoomPath = "chatRooms"
  
  private var chatRoomListener: ListenerRegistration?
  private var subscriptions: Set<AnyCancellable> = []
  
  public init() { }
  
  deinit {
    chatRoomListener?.remove()
  }
  
  func getConversations(forUserWithId userId: String,
                        completion: @escaping (Conversations) -> Void) -> ListenerRegistration? {
    return db.collection(conversationsPath).document(userId)
      .addSnapshotListener { snapshot, error in
        guard let snapshot = snapshot else {
          print("snapshot not available error: \(String(describing: error))")
          return
        }
        guard let conversations = try? snapshot.data(as: Conversations.self) else {
          print("cannot convert data to conversations")
          return
        }
        completion(conversations)
      }
    
  }
  
  func getChatRoom(with chatRoomId: String, completion: @escaping (ChatRoom) -> Void) {
    chatRoomListener = db.collection(self.chatRoomPath)
      .document(chatRoomId)
      .addSnapshotListener { snapshot, error in
        guard let snapshot = snapshot else {
          print("snapshot not available error: \(String(describing: error))")
          return
        }
        guard let chatroom = try? snapshot.data(as: ChatRoom.self) else {
          print("cannot convert data to chatroom")
          return
        }
        completion(chatroom)
      }
  }
  
  func getChatRoom(with chatRoomId: String) -> AnyPublisher<ChatRoom, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      self.db.collection(self.chatRoomPath)
        .document(chatRoomId)
        .addSnapshotListener { snapshot, error in
          guard let snapshot = snapshot else {
            return promise(.failure(error!))
          }
          guard let chatroom = try? snapshot.data(as: ChatRoom.self) else {
            return promise(.failure(NSError()))
          }
          return promise(.success(chatroom))
        }
//        .getDocument(as: ChatRoom.self) { result in
//          switch result {
//          case .success(let chatRoom):
//            promise(.success(chatRoom))
//          case .failure(let error):
//            promise(.failure(error))
//          }
//        }
      
    }.eraseToAnyPublisher()
  }
  
  func sendMessage(
    _ message: Message,
    otherUserType: String,
    toChatRoom chatRoom: ChatRoom) -> AnyPublisher<Void, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      var currentMessages = chatRoom.messages
      currentMessages.append(message)
      self.db.collection(self.chatRoomPath).document(chatRoom.id)
        .setData(["messages": currentMessages.map(\.asObject)], merge: true) { error in
          if let error = error { return promise(.failure(error)) }
          // Update conversations
          self.db.collection(self.conversationsPath)
            .document(chatRoom.userId)
            .getDocument(as: Conversations.self) { result in
              
              var entryConversations = [Conversation]()
              let latestMessage = LatestMessage(
                date: message.dateTimestamp,
                text: message.content,
                isRead: message.isRead)
              
              switch result {
              case .failure(_):
                break
//                let newConversation = Conversation(
//                  id: UUID().uuidString,
//                  chatRoomId: chatRoom.id,
//                  otherUserId: chatRoom.otherUserId,
//                  latestMessage: latestMessage)
//                entryConversations = [newConversation]
              case .success(var convs):
                var targetConversation: Conversation?
                var convIndex = 0
                for (index, conv) in convs.all.enumerated() {
                  if conv.chatRoomId == chatRoom.id {
                    convIndex = index
                    targetConversation = conv
                    break
                  }
                }
                
                // Target conversation does exist, we update the latest message
                if var targetConversation = targetConversation {
                  targetConversation.latestMessage = latestMessage
                  convs.all[convIndex] = targetConversation
                  entryConversations = convs.all
                } else {
                  // User must have deleted the conv
                  let newConversation = Conversation(
                    id: UUID().uuidString,
                    chatRoomId: chatRoom.id,
                    otherUserId: chatRoom.otherUserId,
                    otherUserType: otherUserType,
                    latestMessage: latestMessage)
                  convs.all.append(newConversation)
                  entryConversations = convs.all
                }
              }
              
              self.db.collection(self.conversationsPath)
                .document(chatRoom.userId)
                .setData(["all": entryConversations.map(\.asObject)], merge: true) { error in
                  if let error = error { return promise(.failure(error)) }
                  
                  // Do the same as the above for the recipient user
                  self.db.collection(self.conversationsPath)
                    .document(chatRoom.otherUserId)
                    .getDocument(as: Conversations.self) { result in
                      
                      var entryConversations = [Conversation]()
                      let latestMessage = LatestMessage(
                        date: message.dateTimestamp,
                        text: message.content,
                        isRead: message.isRead)
                      
                      switch result {
                      case .failure(_):
                        let newConversation = Conversation(
                          id: UUID().uuidString,
                          chatRoomId: chatRoom.id,
                          otherUserId: chatRoom.userId,
                          otherUserType: kMerchantType,
                          latestMessage: latestMessage)
                        entryConversations = [newConversation]
                      case .success(var convs):
                        var targetConversation: Conversation?
                        var convIndex = 0
                        for (index, conv) in convs.all.enumerated() {
                          if conv.chatRoomId == chatRoom.id {
                            convIndex = index
                            targetConversation = conv
                            break
                          }
                        }
                        
                        // Target conversation does exist, we update the latest message
                        if var targetConversation = targetConversation {
                          targetConversation.latestMessage = latestMessage
                          convs.all[convIndex] = targetConversation
                          entryConversations = convs.all
                        } else {
                          // User must have deleted the conv
                          let newConversation = Conversation(
                            id: UUID().uuidString,
                            chatRoomId: chatRoom.id,
                            otherUserId: chatRoom.userId,
                            otherUserType: kMerchantType,
                            latestMessage: latestMessage)
                          convs.all.append(newConversation)
                          entryConversations = convs.all
                        }
                      }
                      
                      self.db.collection(self.conversationsPath)
                        .document(chatRoom.otherUserId)
                        .setData(["all": entryConversations.map(\.asObject)], merge: true) { error in
                          if let error = error { return promise(.failure(error)) }
                          return promise(.success(()))
                        }
                    }
                }
              
            }
          
        }
        
    }.eraseToAnyPublisher()
  }
  
  func createNewConversation(userId: String,
                             otherUserId: String,
                             otherUserType: String,
                             message: Message) -> AnyPublisher<ChatRoom, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      let chatRoom = ChatRoom(userId: userId, otherUserId: otherUserId, messages: [message])
      let latestMessage = LatestMessage(date: message.dateTimestamp, text: message.content, isRead: message.isRead)
      let newConversation = Conversation(id: UUID().uuidString, chatRoomId: chatRoom.id, otherUserId: otherUserId, otherUserType: otherUserType, latestMessage: latestMessage)
      let recipientConversation = Conversation(id: UUID().uuidString, chatRoomId: chatRoom.id, otherUserId: userId, otherUserType: kMerchantType, latestMessage: latestMessage)
      
      self.db.collection(self.conversationsPath)
        .document(chatRoom.userId)
        .getDocument(as: Conversations.self) { result in
          switch result {
          case .success(var convs):
            // conv between user and other has not been recorded
            if convs.all.first(where: { $0.otherUserId == otherUserId}) == nil {
              convs.all.append(newConversation)
              self.db.collection(self.conversationsPath)
                .document(chatRoom.userId)
                .setData(["all": convs.all.map(\.asObject)], merge: true)
            }
          case .failure(_):
            // conversation record not found
            self.db.collection(self.conversationsPath)
              .document(chatRoom.userId)
              .setData(["userId": userId, "all": [newConversation.asObject]])
          }
        }
      
      self.db.collection(self.conversationsPath)
        .document(chatRoom.otherUserId)
        .getDocument(as: Conversations.self) { result in
          switch result {
          case .success(var convs):
            // There is a chat room already
            if let conversationWithUser = convs.all.first(where: { $0.otherUserId == userId}) {
              self.db.collection(self.chatRoomPath)
                .document(conversationWithUser.chatRoomId)
                .getDocument(as: ChatRoom.self) { result in
                  switch result {
                  case .failure(let error):
                    return promise(.failure(error))
                  case .success(var room):
                    self.sendMessage(message, otherUserType: kMerchantType, toChatRoom: room)
                      .sink { completion in
                        if case .failure(let error) = completion {
                          return promise(.failure(error))
                        }
                      } receiveValue: { _ in
                        room.messages.append(message)
                        return promise(.success(room))
                      }
                      .store(in: &self.subscriptions)
                  }
                }
            } else {
              convs.all.append(recipientConversation)
              self.db.collection(self.conversationsPath)
                .document(chatRoom.otherUserId)
                .setData(["all": convs.all.map(\.asObject)], merge: true)
              self.createChatRoom(chatRoom) {
                if let error = $0 { return promise(.failure(error)) }
                return promise(.success(chatRoom))
              }
            }
            
          case .failure(_):
            self.db.collection(self.conversationsPath)
              .document(chatRoom.otherUserId)
              .setData(["userId": otherUserId, "all": [recipientConversation.asObject]])
            self.createChatRoom(chatRoom) {
              if let error = $0 { return promise(.failure(error)) }
              return promise(.success(chatRoom))
            }
          }
        }
    }.eraseToAnyPublisher()
    
  }
  
  func getConversation(userId: String, otherUserId: String) -> AnyPublisher<Conversation?, Error> {
    Future { [weak self] promise in
      guard let self = self else { return }
      self.db.collection(self.conversationsPath)
        .document(userId)
        .getDocument(as: Conversations.self) { result in
          switch result {
          case .failure(let error):
            return promise(.failure(error))
          case .success(let convs):
            let convoWithOtherUser = convs.all.filter { $0.otherUserId == otherUserId }.first
            return promise(.success(convoWithOtherUser))
          }
        }
    }.eraseToAnyPublisher()
  }
  
  private func createChatRoom(_ chatRoom: ChatRoom,
                              completion: @escaping (Error?) -> Void) {
    db.collection(chatRoomPath).document(chatRoom.id)
      .setData([
        "id": chatRoom.id,
        "userId": chatRoom.userId,
        "otherUserId": chatRoom.otherUserId,
        "messages": chatRoom.messages.map(\.asObject)
      ]) { error in
        if let error = error {
          completion(error)
          return
        }
        completion(nil)
      }
  }
}
