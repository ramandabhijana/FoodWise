//
//  ImageLocationInputBarAccessoryViewDelegate.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 03/03/22.
//

import UIKit
import CoreLocation
import InputBarAccessoryView

protocol ImageLocationInputBarAccessoryViewDelegate: InputBarAccessoryViewDelegate {
  func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith attachments: [AttachmentManager.Attachment])
  func inputBar(_ inputBar: InputBarAccessoryView, didFinishPickingLocation location: CLLocation)
}

class ImageLocationInputBarAccessoryView: InputBarAccessoryView {
  
  lazy var attachmentManager: AttachmentManager = { [unowned self] in
    let manager = AttachmentManager()
    manager.delegate = self
    return manager
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure() {
    let inputButton = makeInputButton(withSystemImageName: "plus")
    inputButton.onTouchUpInside { [weak self] _ in self?.showInputSheet() }
    inputButton.tintColor = .darkGray
    setLeftStackViewWidthConstant(to: 35, animated: true)
    setStackViewItems([inputButton], forStack: .left, animated: false)
    inputPlugins = [attachmentManager]
  }
  
  override func didSelectSendButton() {
//    super.didSelectSendButton()
    guard attachmentManager.attachments.isEmpty else {
      let delegate = delegate as? ImageLocationInputBarAccessoryViewDelegate
      delegate?.inputBar(self, didPressSendButtonWith: attachmentManager.attachments)
      return
    }
    delegate?.inputBar(self, didPressSendButtonWith: inputTextView.text)
  }
}

// MARK: - Button Helpers
extension ImageLocationInputBarAccessoryView {
  private func makeInputButton(withSystemImageName name: String) -> InputBarButtonItem {
    return InputBarButtonItem()
      .configure { item in
        item.spacing = .fixed(10)
//        item.image = UIImage(systemName: name)?.withRenderingMode(.alwaysTemplate)
        item.image = {
          let config = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 22), scale: .medium)
          return UIImage(systemName: name, withConfiguration: config)
        }()
        item.setSize(CGSize(width: 30, height: 30), animated: false)
      }
  }
  
  @objc func showInputSheet() {
    let alertController = makeAlertController()
    rootViewController?.present(alertController, animated: true, completion: nil)
  }
  
  private func makeAlertController() -> UIAlertController {
    let cameraAction: UIAlertAction = {
      let action = UIAlertAction(
        title: "Camera",
        style: .default) { [weak self] _ in
          self?.presentImagePickerController(sourceType: .camera)
        }
      action.setValue(
        UIImage(systemName: "camera")?.withTintColor(.accentColor, renderingMode: .alwaysOriginal),
        forKey: "image")
      return action
    }()
    let photoLibraryAction: UIAlertAction = {
      let action = UIAlertAction(
        title: "Photo Library",
        style: .default) { [weak self] _ in
          self?.presentImagePickerController(sourceType: .photoLibrary)
        }
      action.setValue(
        UIImage(systemName: "photo")?.withTintColor(.accentColor, renderingMode: .alwaysOriginal),
        forKey: "image")
      return action
    }()
    let locationAction: UIAlertAction = {
      let action = UIAlertAction(
        title: "Location",
        style: .default) { [weak self] _ in
          self?.presentLocationPicker()
//          self?.presentImagePickerController(sourceType: .photoLibrary)
        }
      action.setValue(
        UIImage(systemName: "mappin.and.ellipse")?.withTintColor(.accentColor, renderingMode: .alwaysOriginal),
        forKey: "image")
      return action
      
    }()
    let cancelAction = UIAlertAction(
      title: "Cancel",
      style: .cancel,
      handler: nil)
    let controller = UIAlertController(
      title: nil,
      message: nil,
      preferredStyle: .actionSheet)
    controller.addAction(cameraAction)
    controller.addAction(photoLibraryAction)
    controller.addAction(locationAction)
    controller.addAction(cancelAction)
    return controller
  }
}

extension ImageLocationInputBarAccessoryView {
  private func presentLocationPicker() {
    let sb = UIStoryboard.init(name: "Storyboard", bundle: nil)
    let vc = sb.instantiateViewController(withIdentifier: "LocationPickerViewController") as! LocationPickerViewController
    vc.coordinates = nil
    vc.title = "Pick Location"
    vc.navigationItem.largeTitleDisplayMode = .never
    vc.completion = { [weak self] selectedCoordinate in
      guard let self = self else { return }
      let longitude: Double = selectedCoordinate.longitude
      let latitude: Double = selectedCoordinate.latitude
      (self.delegate as? ImageLocationInputBarAccessoryViewDelegate)?.inputBar(self, didFinishPickingLocation: CLLocation(latitude: latitude, longitude: longitude))
      self.rootViewController?.dismiss(animated: true, completion: nil)
    }
   let presentedVC = UINavigationController(rootViewController: vc)
//    presentedVC.viewControllers = [vc]
    
//    presentedVC.addChild(vc)
//    presentedVC.isNavigationBarHidden = true
//    presentedVC.setViewControllers([vc], animated: false)
    rootViewController?.present(presentedVC, animated: true, completion: nil)
  }
}

// MARK: - AttachmentManagerDelegate
extension ImageLocationInputBarAccessoryView: AttachmentManagerDelegate {
  // Helper method
  private func setAttachmentManagerActive(_ active: Bool) {
    let topStackView = topStackView
    let attachmentViewContainedInTopStackView = topStackView.arrangedSubviews.contains(attachmentManager.attachmentView)
    if active && !attachmentViewContainedInTopStackView {
      topStackView.insertArrangedSubview(
        attachmentManager.attachmentView,
        at: topStackView.arrangedSubviews.count)
      topStackView.layoutIfNeeded()
    } else if !active && attachmentViewContainedInTopStackView {
      topStackView.removeArrangedSubview(attachmentManager.attachmentView)
      topStackView.layoutIfNeeded()
    }
  }
  
  func attachmentManager(_ manager: AttachmentManager, shouldBecomeVisible: Bool) {
    setAttachmentManagerActive(shouldBecomeVisible)
  }
  
  func attachmentManager(_ manager: AttachmentManager, didReloadTo attachments: [AttachmentManager.Attachment]) {
    sendButton.isEnabled = !manager.attachments.isEmpty
  }
  
  func attachmentManager(_ manager: AttachmentManager, didInsert attachment: AttachmentManager.Attachment, at index: Int) {
    sendButton.isEnabled = !manager.attachments.isEmpty
  }
  
  func attachmentManager(_ manager: AttachmentManager, didRemove attachment: AttachmentManager.Attachment, at index: Int) {
    sendButton.isEnabled = !manager.attachments.isEmpty
  }
  
  func attachmentManager(_ manager: AttachmentManager, didSelectAddAttachmentAt index: Int) {
    showInputSheet()
  }
}

// MARK: - UIImagePickerControllerDelegate
extension ImageLocationInputBarAccessoryView: UIImagePickerControllerDelegate {
  func presentImagePickerController(sourceType: UIImagePickerController.SourceType) {
    let pickerController = UIImagePickerController()
    pickerController.delegate = self
    pickerController.allowsEditing = true
    pickerController.sourceType = sourceType
    pickerController.presentationController?.delegate = self
    inputAccessoryView?.isHidden = true
    rootViewController?.present(pickerController, animated: true, completion: nil)
  }
  
  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
  ) {
    if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
      inputPlugins.forEach { _ = $0.handleInput(of: editedImage) }
    } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
      inputPlugins.forEach { _ = $0.handleInput(of: originalImage) }
    }
    rootViewController?.dismiss(animated: true, completion: nil)
    inputAccessoryView?.isHidden = false
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    rootViewController?.dismiss(animated: true, completion: nil)
    inputAccessoryView?.isHidden = false
  }
}

// MARK: - UINavigationControllerDelegate && UIAdaptivePresentationControllerDelegate
extension ImageLocationInputBarAccessoryView: UINavigationControllerDelegate, UIAdaptivePresentationControllerDelegate {
  var rootViewController: UIViewController? {
    let keyWindow = (UIApplication.shared.connectedScenes.first as! UIWindowScene).keyWindow
    return keyWindow?.rootViewController
  }
  
  func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
    isHidden = false
  }
}
