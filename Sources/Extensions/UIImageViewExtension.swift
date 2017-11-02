
//
//  UIImageViewExtension.swift
//  FlaneurImagePickerController
//
//  Created by Flâneur on 25/07/2017.
//  
//

import UIKit
import Photos

extension UIImageView {
    /// Asynchronously sets the image displayed in the image view, from a `PHAsset` instance.
    ///
    /// - Parameters:
    ///   - asset: A representation of an image, video or Live Photo in the Photos library.
    ///   - thumbnail: If `true` the target image size will be 150⨉150. Otherwise it will be the default size of the asset.
    ///   - deliveryMode: The requested image quality and delivery priority.
    ///   - completion: The completion block when an image is available.
    /// - Returns: A numeric identifier for the request. If you need to cancel the request before it completes, pass this identifier to the cancelImageRequest(_:) method.
    func setImageFromPHAsset(asset: PHAsset,
                             thumbnail: Bool,
                             deliveryMode: PHImageRequestOptionsDeliveryMode,
                             completion: ((UIImage?) -> Void)?) -> PHImageRequestID {
        // Add a spinner while the download happens

        // Delete previous activityIndicatorView since cells are reused
        for subview in self.subviews {
            if subview is UIActivityIndicatorView {
                subview.removeFromSuperview()
            }
        }
        
        let indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
        self.addSubview(indicatorView)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        indicatorView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        indicatorView.startAnimating()
        
        var size: CGSize
        if thumbnail {
            size = CGSize(width: 150.0, height: 150.0)
        } else {
            size = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        }

        return asset.requestImage(targetSize: size,
                                  deliveryMode: deliveryMode,
                                  resultHandler: { [weak self] (image, info) in
                                    guard let existingSelf = self,
                                        let image = image else {
                                            indicatorView.stopAnimating()
                                            indicatorView.removeFromSuperview()
                                            return
                                    }
                                    completion?(image)
                                    indicatorView.stopAnimating()
                                    indicatorView.removeFromSuperview()

                                    existingSelf.image = image
        })
    }
}

internal extension PHAsset {
    func requestImage(targetSize: CGSize,
                      deliveryMode: PHImageRequestOptionsDeliveryMode,
                      resultHandler: @escaping(UIImage?, Error?) -> ()) -> PHImageRequestID {
        let manager = PHImageManager.default()

        let options = PHImageRequestOptions()

        // Request the most recent version of the image asset (the one that reflects all edits).
        options.version = .current

        // If the requested image is not stored on the local device, Photos downloads the image from iCloud.
        options.isNetworkAccessAllowed = true

        options.isSynchronous = false
        options.deliveryMode = deliveryMode

        return manager.requestImage(for: self,
                                    targetSize: targetSize,
                                    contentMode: .default,
                                    options: options,
                                    resultHandler: { (image, info) in
                                        resultHandler(image, nil)
        })
    }
}
