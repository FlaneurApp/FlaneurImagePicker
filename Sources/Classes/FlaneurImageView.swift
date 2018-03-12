//
//  FlaneurImageView.swift
//  FlaneurImagePicker
//
//  Created by Mickaël Floc'hlay on 27/10/2017.
//

import UIKit
import Photos

/// A utility wrapping `UIImageView` so that we can set images from descriptors and cancel asynchronous operations
/// when relevant and necessary.
///
/// Since an extension wouldn't allow to store information, subclassing `UIImageView` was necessary.
final public class FlaneurImageView: UIImageView {
    /// Specifies if Photos Assets should be fetched as thumbnails or not.
    public var assetThumbnailMode: Bool = false

    enum AsynchronousState {
        case none
        case kingfisher
        case asset(_: PHImageRequestID)
    }

    private var asynchronousState: AsynchronousState = .none

    /// Sets the image using an image descriptor.
    ///
    /// - Parameter imageDescription: the descriptor of the image being used.
    public func setImage(with imageDescription: FlaneurImageDescriptor) {
        switch imageDescription {
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

    /// Prepares the instance to be reused.
    ///
    /// Since some asynchronous operations might be in progress, you should call this method to cancel them
    /// before reusing the instance. For instance, if the instance has a `UITableViewCell` parent view, calling
    /// this method is necessary to avoid races between operations.
    public func prepareForReuse() {
        switch asynchronousState {
        case .kingfisher:
            self.kf.cancelDownloadTask()
        case .asset(let requestID):
            PHImageManager.default().cancelImageRequest(requestID)
        case .none:
            () // Do nothing
        }

        self.image = nil
    }
}
