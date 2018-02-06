//
//  FlaneurImageLibraryProvider.swift
//  FlaneurImagePickerController
//
//  Created by Flâneur on 24/07/2017.
//  
//

import UIKit
import Photos

/// An image provider using the device's photo library.
final class FlaneurImageLibraryProvider: NSObject, FlaneurImageProvider {
    weak var delegate: FlaneurImageProviderDelegate?

    let fetchLimit: Int
    
    init(fetchLimit: Int = 0) {
        self.fetchLimit = fetchLimit
        super.init()
    }

    func isAuthorized() -> Bool {
        return PHPhotoLibrary.authorizationStatus() == .authorized
    }
    
    func requestAuthorization(_ handler: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { newStatus in
            handler(newStatus == .authorized)
        }
    }
    
    func fetchImagesFromSource() {
        guard let delegate = delegate else { return }

        let assetsList = PHAsset.fetchAssets(with: .image, options: .latest(fetchLimit))
        var images: [FlaneurImageDescription] = []

        for i in 0..<assetsList.count {
            if let imageDescription = FlaneurImageDescription(asset: assetsList[i]) {
                images.append(imageDescription)
            }
        }
        
        delegate.didLoadImages(images: images)
    }
    
    func fetchNextPage() {
        ()
    }
}
