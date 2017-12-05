//
//  FlaneurImageCameraProvider.swift
//  FlaneurImagePickerController
//
//  Created by Flâneur on 24/07/2017.
//  
//

import UIKit
import AVFoundation

final class FlaneurImageCameraProvider: NSObject, FlaneurImageProvider {
    weak var delegate: FlaneurImageProviderDelegate?
    weak var parentVC: UIViewController?
    
    var picker = UIImagePickerController()

    init(delegate: FlaneurImageProviderDelegate, andParentVC parentVC: UIViewController) {
        self.delegate = delegate
        self.parentVC = parentVC

        super.init()
        self.picker.delegate = self
    }

    func isAuthorized() -> Bool {
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == AVAuthorizationStatus.authorized {
            return true
        }
        return false
    }

    func askForPermission(isPermissionGiven: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if response {
                return isPermissionGiven(true)
            } else {
                return isPermissionGiven(false)
            }
        }
    }

    func fetchImagesFromSource() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            delegate?.didFailLoadingImages(with: .camera)
            return
        }

        picker.allowsEditing = false
        picker.sourceType = .camera
        parentVC?.present(picker, animated: true)
    }
    
    func fetchNextPage() {
        // Not usefull here
    }
}

extension FlaneurImageCameraProvider: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        if let flaneurImageDescription = FlaneurImageDescription(image: image) {
            delegate?.didLoadImages(images: [flaneurImageDescription])
        }
        
        self.picker.dismiss(animated: true, completion: nil)
    }
}
