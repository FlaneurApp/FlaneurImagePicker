//
//  FlaneurImageLibraryProvider.swift
//  FlaneurImagePickerController
//
//  Created by Flâneur on 24/07/2017.
//  
//

import UIKit
import Photos

/// User's library source, needs "Privacy - Photo Library Usage Description" set in info.plist
final public class FlaneurImageLibraryProvider: NSObject, FlaneurImageProvider {
    weak public var delegate: FlaneurImageProviderDelegate?

    public let name = "library"

    let fetchLimit: Int
    
    public init(fetchLimit: Int = 0) {
        self.fetchLimit = fetchLimit
        super.init()
    }

    public func isAuthorized() -> Bool {
        return PHPhotoLibrary.authorizationStatus() == .authorized
    }
    
    public func requestAuthorization(_ handler: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { newStatus in
            handler(newStatus == .authorized)
        }
    }
    
    public func fetchImagesFromSource() {
        guard let delegate = delegate else { return }

        let assetsList = PHAsset.fetchAssets(with: .image, options: .latest(fetchLimit))
        var images: [FlaneurImageDescriptor] = []

        for i in 0..<assetsList.count {
            images.append(FlaneurImageDescriptor.phAsset(assetsList[i]))
        }

        delegate.imageProvider(self, didLoadImages: images)
    }
    
    public func fetchNextPage() {
        debugPrint("no pagination for provider: \(name)")
    }
}
