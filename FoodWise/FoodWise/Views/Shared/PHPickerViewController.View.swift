import PhotosUI
import SwiftUI

extension PHPickerViewController {
  struct View {
    let selectionLimit: Int
    @Binding var imageData: Data?
  }
}

// MARK: - UIViewControllerRepresentable
extension PHPickerViewController.View: UIViewControllerRepresentable {
  func makeCoordinator() -> some PHPickerViewControllerDelegate {
    PHPickerViewController.Delegate(imageData: $imageData)
  }

  func makeUIViewController(context: Context) -> PHPickerViewController {
    var configuration = PHPickerConfiguration()
    configuration.selectionLimit = selectionLimit
    configuration.filter = .images
    let picker = PHPickerViewController(configuration: configuration)
    picker.delegate = context.coordinator
    return picker
  }

  func updateUIViewController(_: UIViewControllerType, context _: Context) { }
}

// MARK: - PHPickerViewControllerDelegate
extension PHPickerViewController.Delegate: PHPickerViewControllerDelegate {
  func picker(
    _ picker: PHPickerViewController,
    didFinishPicking results: [PHPickerResult]
  ) {
    results.first?.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
      if let originalImage = image as? UIImage {
        DispatchQueue.main.async { [weak self] in
          self?.imageData = originalImage.jpegData(compressionQuality: 0.5)
        }
      }
    }
    picker.dismiss(animated: true)
  }
}

// MARK: - private
private extension PHPickerViewController {
  final class Delegate {
    init(imageData: Binding<Data?>) {
      self._imageData = imageData
    }

    @Binding var imageData: Data?
  }
}
