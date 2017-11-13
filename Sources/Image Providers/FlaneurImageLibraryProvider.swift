//
//  FlaneurImageLibraryProvider.swift
//  FlaneurImagePickerController
//
//  Created by Flâneur on 24/07/2017.
//  
//

import UIKit
import Photos

final class FlaneurImageLibraryProvider: NSObject, FlaneurImageProvider {
    weak var delegate: FlaneurImageProviderDelegate?
    weak var parentVC: UIViewController?
    
    private let config: FlaneurImagePickerConfig
    
    init(delegate: FlaneurImageProviderDelegate, andParentVC parentVC: UIViewController) {
        self.delegate = delegate
        self.config = FlaneurImagePickerConfig()
        self.parentVC = parentVC

        super.init()
    }

    init(delegate: FlaneurImageProviderDelegate, andConfig config: FlaneurImagePickerConfig) {
        self.delegate = delegate
        self.config = config

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
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [ sortDescriptor ]
        fetchOptions.fetchLimit = 1200

        let assetsList = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        var images = [FlaneurImageDescription]()
        for i in 0..<assetsList.count {
            if let imageDescription = FlaneurImageDescription(asset: assetsList[i]) {
                images.append(imageDescription)
            }
        }
        self.delegate?.didLoadImages(images: images)
    }
    
    func fetchNextPage() {
        // Not useful here
    }
}
