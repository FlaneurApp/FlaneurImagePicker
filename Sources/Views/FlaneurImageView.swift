//
//  FlaneurImageView.swift
//  FlaneurImagePicker
//
//  Created by Mickaël Floc'hlay on 27/10/2017.
//

import UIKit
import Photos

class FlaneurImageView: UIImageView {
    enum AsynchronousState {
        case none
        case kingfisher
        case asset(_: PHImageRequestID)
    }

    private var asynchronousState: AsynchronousState = .none

    var assetThumbnailMode: Bool = false

    func setImage(with imageDescription: FlaneurImageDescription) {
        switch imageDescription.sourceType {
        case .url(let imageURL):
            asynchronousState = .kingfisher
            self.kf.indicatorType = .activity
            self.kf.setImage(with: imageURL,
                             placeholder: nil,
                             options: nil,
                             progressBlock: nil,
                             completionHandler: { [weak self] (image, error, cacheType, url) in
                                self?.asynchronousState = .none
            })

        case .image(let image):
            asynchronousState = .none
            self.image = image

        case .phAsset(let asset):
            asynchronousState = .asset(self.setImageFromPHAsset(asset: asset,
                                                                thumbnail: assetThumbnailMode,
                                                                deliveryMode: (assetThumbnailMode ? .opportunistic : .highQualityFormat),
                                                                completion: { [weak self] image in
                                                                    self?.asynchronousState = .none
            }))
        }
    }

    func prepareForReuse() {
        switch asynchronousState {
        case .kingfisher:
            self.kf.cancelDownloadTask()
        case .asset(let requestID):
            PHImageManager.default().cancelImageRequest(requestID)
        case .none:
            debugPrint("no asynchonous state => do nothing")
        }

        self.image = nil
    }
}
