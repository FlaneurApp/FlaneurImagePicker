
//
//  UIImageViewExtension.swift
//  FlaneurImagePickerController
//
//  Created by Frenchapp on 25/07/2017.
//  
//

import UIKit
import Photos

extension UIImageView {
    func setImageFromPHAsset(asset: PHAsset, thumbnail: Bool, deliveryMode: PHImageRequestOptionsDeliveryMode, completion: ((UIImage?) -> Void)?) -> PHImageRequestID {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .current
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false
        options.deliveryMode = deliveryMode

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
            size = CGSize(width: 150, height: 150)
        } else {
            size = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        }
        
        return manager.requestImage(for: asset,
                             targetSize: size,
                             contentMode: .default,
                             options: options,
                             resultHandler: { [weak self] (image, infos) in
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
