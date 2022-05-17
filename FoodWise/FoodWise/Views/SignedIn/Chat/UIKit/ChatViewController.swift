//
//  ChatViewController.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 02/03/22.
//

import UIKit
import Combine
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController {
  private var subscriptions = Set<AnyCancellable>()
  private var collectionViewContentOffset: CGPoint?
  private var collectionViewContentOffsetObservation: NSKeyValueObservation?
  
  private lazy var tapRecognizer = UITapGestureRecognizer(
    target: self,
    action: #selector(didTapCollectionView(_:))
  )
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(.backgroundColor)
    configureMessageCollectionView()
    setupKeyboardShowedNotification()
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(textViewBeganEditing(_:)),
      name: UITextView.textDidBeginEditingNotification,
      object: nil)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(textViewTextDidChange(_:)),
      name: UITextView.textDidChangeNotification,
      object: nil)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(textViewFinishedEditing(_:)),
      name: UITextView.textDidEndEditingNotification,
      object: nil)
    
    collectionViewContentOffsetObservation = messagesCollectionView.observe(\.contentOffset, options: [.old], changeHandler: { [weak self] collectionView, change in
      self?.collectionViewContentOffset = change.oldValue
    })
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    becomeFirstResponder()
    // setting the vc to be first responder caused the keyboard to show and tap gestured to be registered, need to remove the gesture afterwards
    removeTapGestureOnCollectionView()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
      self?.messagesCollectionView.scrollToLastItem(animated: false)
    }
  }
  
  func configureMessageCollectionView() {
    messagesCollectionView.backgroundColor = UIColor(.backgroundColor)
    addTapGestureOnCollectionView()
    adjustMessageAlignment()
    scrollsToLastItemOnKeyboardBeginsEditing = false
    maintainPositionOnKeyboardFrameChanged = true
    showMessageTimestampOnSwipeLeft = true
  }
  
  func configureMessageInputBar(
    _ inputBar: InputBarAccessoryView,
    delegate: InputBarAccessoryViewDelegate
  ) {
    messageInputBar = inputBar
    messageInputBar.delegate = delegate
    messageInputBar.isTranslucent = false
    messageInputBar.backgroundView.backgroundColor = UIColor(.secondaryColor)
    messageInputBar.sendButton.setTitleColor(.accentColor, for: .normal)
    messageInputBar.sendButton.setTitleColor(.accentColor.withAlphaComponent(0.3),
      for: .highlighted)
    messageInputBar.separatorLine.isHidden = true
    messageInputBar.inputTextView.tintColor = .accentColor
    messageInputBar.inputTextView.backgroundColor = UIColor.white
    messageInputBar.inputTextView.layer.borderWidth = 1.0
    messageInputBar.inputTextView.layer.cornerRadius = 16.0
    messageInputBar.inputTextView.layer.borderColor = UIColor.darkGray.cgColor
    messageInputBar.inputTextView.layer.masksToBounds = true
    messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 36)
    messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 36)
    messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    configureInputBarItems()
  }
  
  private func configureInputBarItems() {
    messageInputBar.setRightStackViewWidthConstant(to: 36, animated: false)
    messageInputBar.sendButton.imageView?.backgroundColor = UIColor(white: 0.85, alpha: 1)
    messageInputBar.sendButton.imageView?.layer.cornerRadius = 16
    messageInputBar.sendButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    messageInputBar.sendButton.setSize(CGSize(width: 36, height: 36), animated: false)
    messageInputBar.sendButton.image = UIImage(named: "ic_up")
    messageInputBar.sendButton.title = nil
    messageInputBar.padding.bottom = 8
    messageInputBar.middleContentViewPadding.right = -38
    messageInputBar.inputTextView.textContainerInset.bottom = 8
    messageInputBar.sendButton
      .onEnabled { item in
        UIView.animate(withDuration: 0.3) {
          item.imageView?.backgroundColor = .accentColor
        }
      }
      .onDisabled { item in
        UIView.animate(withDuration: 0.3) {
          item.imageView?.backgroundColor = UIColor(white: 0.85, alpha: 1)
        }
      }
  }
  
  func listenMessagesChanged(publisher: AnyPublisher<[MessageType], Never>) {
    publisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] messages in
        self?.messagesCollectionView.reloadDataAndKeepOffset()
        self?.messagesCollectionView.scrollToLastItem(animated: true)
      }
      .store(in: &subscriptions)
  }
  
  private func setupKeyboardShowedNotification() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardDidShow(_:)),
      name: UIResponder.keyboardDidShowNotification,
      object: nil)
  }
  
}

// MARK: - Helpers
extension ChatViewController {
  private func addTapGestureOnCollectionView() {
    print("\nAdding tap gesture: \(tapRecognizer.description)")
    messagesCollectionView.addGestureRecognizer(tapRecognizer)
  }
  
  private func removeTapGestureOnCollectionView() {
    print("\nRemoving tap gesture: \(tapRecognizer.description)")
    messagesCollectionView.removeGestureRecognizer(tapRecognizer)
  }
  
  @objc func didTapCollectionView(_ sender: UITapGestureRecognizer) {
    messageInputBar.inputTextView.resignFirstResponder()
  }
  
  @objc func keyboardDidShow(_ notification: NSNotification) {
    self.messagesCollectionView.contentInset.bottom /= 2
    
  }
  
  @objc func textViewBeganEditing(_ notification: NSNotification) {
    addTapGestureOnCollectionView()
  }
  
  // To resolve an issue that cause unwanted content offset
  @objc func textViewTextDidChange(_ notification: NSNotification) {
    guard let offset = collectionViewContentOffset else { return }
    messagesCollectionView.setContentOffset(offset, animated: false)
    collectionViewContentOffset = nil
  }
  
  @objc func textViewFinishedEditing(_ notification: NSNotification) {
    removeTapGestureOnCollectionView()
  }
  
  private func initcollectionViewContentOffsetObservation() {
    collectionViewContentOffsetObservation = messagesCollectionView.observe(\.contentOffset, options: [.old], changeHandler: { [weak self] collectionView, change in
      print("\ncHANGE Handler: \(collectionView.contentOffset)")
      self?.collectionViewContentOffset = change.oldValue
    })
  }
}

extension ChatViewController {
  // Helper
  private func adjustMessageAlignment() {
    guard let layout = messagesCollectionView.collectionViewLayout
            as? MessagesCollectionViewFlowLayout else {
      return
    }
    layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
    layout.textMessageSizeCalculator.incomingAvatarSize = .zero
    layout.setMessageIncomingAvatarSize(.zero)
    layout.setMessageOutgoingAvatarSize(.zero)
    
    // Top alignment
    let incomingTopLabelAlignment = LabelAlignment(
      textAlignment: .left,
      textInsets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0))
    layout.setMessageIncomingMessageTopLabelAlignment(incomingTopLabelAlignment)
    let outgoingTopLabelAlignment = LabelAlignment(
      textAlignment: .right,
      textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15))
    layout.setMessageOutgoingMessageTopLabelAlignment(outgoingTopLabelAlignment)
    
    // Bottom alignment
    let incomingBottomLabelAlignment = LabelAlignment(
      textAlignment: .left,
      textInsets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0))
    layout.setMessageIncomingMessageBottomLabelAlignment(incomingBottomLabelAlignment)
    let outgoingBottomLabelAlignment = LabelAlignment(
      textAlignment: .right,
      textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15))
    layout.setMessageOutgoingMessageBottomLabelAlignment(outgoingBottomLabelAlignment)
  }
}


