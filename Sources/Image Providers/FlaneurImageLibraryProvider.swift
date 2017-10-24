//
//  FlaneurImageLibraryProvider.swift
//  FlaneurImagePickerController
//
//  Created by Frenchapp on 24/07/2017.
//  
//

import UIKit
import Photos

final class FlaneurImageLibraryProvider: NSObject, FlaneurImageProvider {

    var delegate: FlaneurImageProviderDelegate?
    weak var parentVC: UIViewController?
    
    private let config: FlaneurImagePickerConfig
    
    private let thumbnailSize: CGSize
    
    init(delegate: FlaneurImageProviderDelegate, andParentVC parentVC: UIViewController) {
        self.delegate = delegate
        self.config = FlaneurImagePickerConfig()
        self.parentVC = parentVC
        self.thumbnailSize = CGSize(width: config.sizeForImagesPickerView.width * 2,
                                    height: config.sizeForImagesPickerView.height * 2)
        super.init()
    }

    init(delegate: FlaneurImageProviderDelegate, andConfig config: FlaneurImagePickerConfig) {
        self.delegate = delegate
        self.config = config
        self.thumbnailSize = CGSize(width: config.sizeForImagesPickerView.width * 2,
                                    height: config.sizeForImagesPickerView.height * 2)
        super.init()
    }
    
    func isAuthorized() -> Bool {
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            return true
        }
        return false
    }
    
    func askForPermission(isPermissionGiven: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization({
            (newStatus) in
            if newStatus ==  PHAuthorizationStatus.authorized {
                return isPermissionGiven(true)
            }
            return isPermissionGiven(false)
        })
    }
    
    func fetchImagesFromSource() {
        let assetsList = PHAsset.fetchAssets(with: .image, options: nil)
        var images = [FlaneurImageDescription]()
        for i in 0..<assetsList.count {
            if let imageDescription = FlaneurImageDescription(asset: assetsList[i]) {
                images.append(imageDescription)
            }
        }
        self.delegate?.didLoadImages(images: images)
    }
    
    func fetchNextPage() {
        // Not usefull here
    }
}
