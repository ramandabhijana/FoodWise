//
//  Coordinator+InputBarAccessoryViewDelegate.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 02/03/22.
//

import MessageKit
import InputBarAccessoryView
import Combine
import UIKit
import CoreLocation


//extension ChatView.Coordinator: InputBarAccessoryViewDelegate {
extension ChatViewViewControllerRepresentation.Coordinator: ImageLocationInputBarAccessoryViewDelegate {
  func inputBar(_ inputBar: InputBarAccessoryView,
                didPressSendButtonWith attachments: [AttachmentManager.Attachment]) {
    let messageId = UUID().uuidString
    let placeholderImage = UIImage(systemName: "photo.artframe")?.withTintColor(.secondaryLabel) ?? UIImage()
    let sender = Sender(senderId: userId, displayName: "", photoURL: "")
    for (index, attachment) in attachments.enumerated() {
      if case .image(let image) = attachment {
        if let imageData = image.pngData() {
          sendMessage(messageId: messageId, imageData: imageData, imageAtIndex: index)
        } else if let imageData = image.jpegData(compressionQuality: 0.5) {
          sendMessage(messageId: messageId, imageData: imageData, imageAtIndex: index)
        }
      }
    }
    inputBar.invalidatePlugins()
    
    func sendMessage(messageId: String, imageData: Data, imageAtIndex index: Int) {
      StorageService.shared.uploadPictureData(imageData, path: .chatPictures(fileName: "\(messageId)_\(index)"))
        .map { [weak self] url -> Message? in
          guard let self = self else { return nil }
          let media = Media(url: url, image: nil, placeholderImage: placeholderImage, size: .zero)
          let messageType = MessageTypeImpl(messageId: messageId, sentDate: .now, kind: .photo(media), sender: sender)
          let message = self.transformToMessage(messageType)
          return message
        }
        .flatMap { [weak self] message -> AnyPublisher<ChatRoom, Error> in
          guard let self = self,
                let message = message else {
                  return Fail(error: NSError()).eraseToAnyPublisher()
                }
          if self.shouldCreateNewConversation {
            return self.repository.createNewConversation(userId: self.userId, otherUserId: self.otherUserId, otherUserType: self.otherUserType, message: message)
          } else {
            guard let chatRoom = self.chatRoom else {
              return Fail(error: NSError()).eraseToAnyPublisher()
            }
            return self.repository.sendMessage(message, otherUserType: self.otherUserType, toChatRoom: chatRoom)
              .map { _ in chatRoom }
              .eraseToAnyPublisher()
          }
        }
        .sink { completion in
          if case .failure(let error) = completion {
            print("Fail sending text message with error: \(error)")
          }
        } receiveValue: { [weak self] chatRoom in
          guard let self = self else { return }
          if self.chatRoom == nil {
            self.chatRoom = chatRoom
            self.messages.append(self.transformToMessageType(chatRoom.messages.first(where: { $0.id == messageId })!))
            self.fetchChatRoom(chatRoomId: chatRoom.id)
          } else {
            self.messagesChangedSubject.send(self.messages)
          }
        }
        .store(in: &subscriptions)
    }
  }
  
  func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
    let messageType = MessageTypeImpl(messageId: UUID().uuidString, sentDate: .now, kind: .text(text), sender: Sender(senderId: userId, displayName: "", photoURL: ""))
    sendMessage(with: messageType, inputBar: inputBar)
  }
  
  func inputBar(_ inputBar: InputBarAccessoryView, didFinishPickingLocation location: CLLocation) {
    let location = Location(
      location: location, size: .zero)
    let messageId = UUID().uuidString
    let messageType = MessageTypeImpl(messageId: messageId, sentDate: .now, kind: .location(location), sender: Sender(senderId: userId, displayName: "", photoURL: ""))
    sendMessage(with: messageType, inputBar: inputBar)
  }
  
  private func sendMessage(with messageType: MessageTypeImpl, inputBar: InputBarAccessoryView) {
    let message = transformToMessage(messageType)
    inputBar.inputTextView.text = String()
    inputBar.invalidatePlugins()
    inputBar.sendButton.startAnimating()
    inputBar.inputTextView.placeholder = "Sending..."
    inputBar.inputTextView.resignFirstResponder()
    
    if shouldCreateNewConversation {
      repository.createNewConversation(userId: userId, otherUserId: otherUserId, otherUserType: otherUserType, message: message)
        .subscribe(on: DispatchQueue.global(qos: .default))
        .receive(on: DispatchQueue.main)
        .sink { completion in
          if case .failure(let error) = completion {
            print("Fail sending text message with error: \(error)")
          }
          inputBar.sendButton.stopAnimating()
          inputBar.inputTextView.placeholder = "Aa"
        } receiveValue: { [weak self] chatRoom in
          guard let self = self else { return }
          self.chatRoom = chatRoom
          self.messages.append(messageType)
          self.messagesChangedSubject.send(self.messages)
          self.fetchChatRoom(chatRoomId: chatRoom.id)
        }
        .store(in: &subscriptions)
    } else {
      guard let chatRoom = chatRoom else { return }
      repository.sendMessage(message, otherUserType: otherUserType, toChatRoom: chatRoom)
        .subscribe(on: DispatchQueue.global(qos: .default))
        .receive(on: DispatchQueue.main)
        .sink { completion in
          if case .failure(let error) = completion {
            print("Fail sending text message with error: \(error)")
          }
          inputBar.sendButton.stopAnimating()
          inputBar.inputTextView.placeholder = "Aa"
        } receiveValue: { [weak self] _ in
          guard let self = self else { return }
          self.messagesChangedSubject.send(self.messages)
        }
        .store(in: &subscriptions)
    }
  }
}
