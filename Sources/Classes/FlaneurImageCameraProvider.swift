//
//  FlaneurImageCameraProvider.swift
//  FlaneurImagePickerController
//
//  Created by Flâneur on 24/07/2017.
//  
//

import UIKit
import AVFoundation

enum FlaneurImageCameraProviderError: LocalizedError {
    case providerNotAvailableOnThisDevice
}

/// User's camera source, needs "Privacy - Camera Usage Description" set in info.plist
final public class FlaneurImageCameraProvider: NSObject, FlaneurImageProvider {
    weak public var delegate: FlaneurImageProviderDelegate?

    public let name = "camera"

    lazy var picker: UIImagePickerController = {
        let result = UIImagePickerController()
        result.delegate = self
        result.allowsEditing = false
        result.sourceType = .camera
        return result
    }()

    public func isAuthorized() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }

    public func requestAuthorization(_ handler: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { response in
            handler(response)
        }
    }

    public func fetchImagesFromSource() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            delegate?.imageProvider(self, didFailWithError: FlaneurImageCameraProviderError.providerNotAvailableOnThisDevice)
            return
        }

        delegate?.presentingViewController(for: self).present(picker, animated: true)
    }
    
    public func fetchNextPage() {
        // Not usefull here
    }
}

extension FlaneurImageCameraProvider: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("No image found after the user finished picking media")
        }
        delegate?.imageProvider(self, didLoadImages: [FlaneurImageDescriptor.image(image)])
        picker.dismiss(animated: true, completion: nil)
    }
}
