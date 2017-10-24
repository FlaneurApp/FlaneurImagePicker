//
//  PickerCell.swift
//  FlaneurImagePickerController
//
//  Created by Frenchapp on 14/07/2017.
//  
//

import UIKit
import Photos

final class PickerCell: UICollectionViewCell {
    
    var requestID: PHImageRequestID?
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .black
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        self.contentView.addSubview(view)
        return view
    }()
    
    private weak var imageDescription: FlaneurImageDescription!
    
    override func layoutSubviews() {
        super.layoutSubviews()

        imageView.frame = contentView.bounds
    }
    
    func cancelCurrentRequestIfExist() {
        if let requestID = requestID {
            let manager = PHImageManager.default()
            manager.cancelImageRequest(requestID)
            self.requestID = nil
        }
    }
    
    func configure(with config: FlaneurImagePickerConfig, andImageDescription imageDescription: FlaneurImageDescription) {

        cancelCurrentRequestIfExist()

        self.imageDescription = imageDescription

        self.imageView.image = nil
        switch imageDescription.imageSource! {
        case .urlBased:
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: imageDescription.imageURL)
        
        case .imageBased:
            imageView.image = imageDescription.image
        
        case .phassetBased:
            if let image = imageDescription.image {
                imageView.image = image
                return
            }
            requestID = imageView.setImageFromPHAsset(asset: imageDescription.associatedPHAsset,
                                                      thumbnail: true,
                                                      deliveryMode: .opportunistic,
                                                      completion:  nil)
        }
    }
}
