//
//  ChatView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 02/03/22.
//

import SwiftUI
import Combine
import MessageKit
import CoreLocation
import FirebaseFirestore

struct ChatViewViewControllerRepresentation: UIViewControllerRepresentable {
  @State private var messages: [MessageType] = []
  
  private let userId: String
  private let otherUserId: String
  private let otherUserType: String
  private let chatRoomId: String?
  
  init(userId: String, otherUserId: String, otherUserType: String, chatRoomId: String?) {
    self.userId = userId
    self.otherUserId = otherUserId
    self.otherUserType = otherUserType
    self.chatRoomId = chatRoomId
  }
  
  func makeUIViewController(context: Context) -> ChatViewController {
    let viewController = ChatViewController()
    viewController.messagesCollectionView.messagesDisplayDelegate = context.coordinator
    viewController.messagesCollectionView.messagesLayoutDelegate = context.coordinator
    viewController.messagesCollectionView.messagesDataSource = context.coordinator
    viewController.messagesCollectionView.messageCellDelegate = context.coordinator
    viewController.configureMessageInputBar(
      ImageLocationInputBarAccessoryView(),
      delegate: context.coordinator)
    viewController.listenMessagesChanged(publisher: context.coordinator.messagesChangedPublisher)
    context.coordinator.cellDelegate = viewController
    return viewController
  }
  
  func updateUIViewController(_ uiViewController: ChatViewController, context: Context) { }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(messages: $messages, userId: userId, otherUserId: otherUserId, otherUserType: otherUserType, chatRoomId: chatRoomId)
  }
}


// MARK: - Coordinator
extension ChatViewViewControllerRepresentation {
  final class Coordinator {
    @Binding var messages: [MessageType]
    public weak var cellDelegate: CoordinatorCellDelegate?
    
    private(set) var repository: ChatRepository
    var subscriptions = Set<AnyCancellable>()
    
    private(set) var userId: String
    private(set) var otherUserId: String
    private(set) var otherUserType: String
    var chatRoomId: String?
    var chatRoom: ChatRoom? {
      didSet { chatRoomId = chatRoom?.id }
    }
    
    var shouldCreateNewConversation: Bool { chatRoomId == nil }
    
    lazy var messageBottomDateFormatter: DateFormatter = {
      let formatter = DateFormatter()
      formatter.dateStyle = .none
      formatter.timeStyle = .short
      return formatter
    }()
    lazy var messageTimestampDateFormatter: DateFormatter = {
      let formatter = DateFormatter()
      formatter.dateStyle = .medium
      formatter.timeStyle = .none
      formatter.locale = Locale(identifier: "en_US")
      return formatter
    }()
    
    // MARK: - Internal Publisher
    internal var messagesChangedSubject = PassthroughSubject<[MessageType], Never>()
    
    // MARK: - Public publisher
    public var messagesChangedPublisher: AnyPublisher<[MessageType], Never> {
      messagesChangedSubject.eraseToAnyPublisher()
    }
    
    init(messages: Binding<[MessageType]>,
         userId: String,
         otherUserId: String,
         otherUserType: String,
         chatRoomId: String?,
         repository: ChatRepository = ChatRepository()) {
      _messages = messages
      self.repository = repository
      self.userId = userId
      self.otherUserId = otherUserId
      self.otherUserType = otherUserType
      self.chatRoomId = chatRoomId
      if let chatRoomId = chatRoomId {
        self.fetchChatRoom(chatRoomId: chatRoomId)
      } else {
        fetchConvoChatRoom(userId: userId, otherUserId: otherUserId)
      }
    }
    
    private func fetchConvoChatRoom(userId: String, otherUserId: String) {
      repository.getConversation(userId: userId, otherUserId: otherUserId)
        .compactMap { $0 }
        .sink { completion in
          
        } receiveValue: { [weak self] convo in
          self?.chatRoomId = convo.chatRoomId
          self?.fetchChatRoom(chatRoomId: convo.chatRoomId)
        }
        .store(in: &subscriptions)
    }
    
    func fetchChatRoom(chatRoomId: String) {
      repository.getChatRoom(with: chatRoomId) { [weak self] chatRoom in
        guard let self = self else { return }
//        if self.chatRoom == nil { self.chatRoom = chatRoom }
        let messages = chatRoom.messages.map(self.transformToMessageType(_:))
//        self.chatRoom?.messages = chatRoom.messages
        self.chatRoom = chatRoom
        self.messages = messages
        self.messagesChangedSubject.send(messages)
      }
    }
    
//    private func fetchChatRoom(chatRoomId: String) {
//      repository.getChatRoom(with: chatRoomId)
//        .sink { completion in
//          if case .failure(let error) = completion {
//            print("Error fetching chat room with error: \(error)")
//          }
//        } receiveValue: { [weak self] chatRoom in
//          guard let self = self else { return }
//          if self.chatRoom == nil { self.chatRoom = chatRoom }
//          let messages = chatRoom.messages.map(self.transformToMessageType(_:))
//          self.messages = messages
//          self.messagesChangedSubject.send(messages)
//        }
//        .store(in: &subscriptions)
//    }
    
    func transformToMessage(_ messageType: MessageType) -> Message {
      let content: String = {
        if case .text(let messageText) = messageType.kind {
          return messageText
        } else if case .photo(let mediaItem) = messageType.kind {
          if let urlString = mediaItem.url?.absoluteString {
            return urlString
          }
        } else if case .location(let locationData) = messageType.kind {
          let location = locationData.location
          return "\(location.coordinate.longitude),\(location.coordinate.latitude)"
        }
        return ""
      }()
      return Message(id: messageType.messageId, type: messageType.kind.description, content: content, dateTimestamp: Timestamp(date: messageType.sentDate), senderId: messageType.sender.senderId, isRead: false)
    }
    
    func transformToMessageType(_ message: Message) -> MessageTypeImpl {
      let kind: MessageKind = {
        if message.type == "photo" {
          guard
            let imageURL = URL(string: message.content),
            let placeHolder = UIImage(systemName: "photo.artframe")
            else { fatalError("Unable to unwrap url or placeholder") }
          let media = Media(
            url: imageURL,
            image: nil,
            placeholderImage: placeHolder.withTintColor(.secondaryLabel, renderingMode: .alwaysOriginal),
            size: CGSize(width: 300, height: 300)
          )
          return .photo(media)
        } else if message.type == "text" {
          return .text(message.content)
        } else if message.type == "location" {
          let locationComponents = message.content.components(separatedBy: ",")
          let (longitude,latitude) = ( Double(locationComponents[0])!, Double(locationComponents[1])! )
          let location = Location(
            location: CLLocation(latitude: latitude, longitude: longitude),
            size: CGSize(width: 300, height: 300)
          )
          return .location(location)
        } else {
          fatalError("Unresolved message type")
        }
      }()
      return MessageTypeImpl(
        messageId: message.id,
        sentDate: message.dateTimestamp.dateValue(),
        kind: kind,
        sender: Sender(senderId: message.senderId,
                       displayName: "", photoURL: ""))
    }
  }
}

