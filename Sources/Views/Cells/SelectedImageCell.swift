//
//  SelectedImageCell.swift
//  FlaneurImagePickerController
//
//  Created by Frenchapp on 14/07/2017.
//  
//

import UIKit
import ActionKit

final class SelectedImageCell: UICollectionViewCell {
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        self.contentView.addSubview(view)
        return view
    }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        self.contentView.insertSubview(button, aboveSubview: self.imageView)
        return button
    }()
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true
        
        
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive = true
        deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        
    }

    func configure(with imageDescription: FlaneurImageDescription!,
                   config: FlaneurImagePickerConfig,
                   andRemoveClosure removeClosure: @escaping ActionKitControlClosure) {
        imageView.image = nil
        
        imageView.contentMode = config.selectedImagesContentMode
        
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
            let _ = imageView.setImageFromPHAsset(asset: imageDescription.associatedPHAsset,
                                                  thumbnail:  false,
                                                  deliveryMode: .highQualityFormat,
                                                  completion: { image in
                                                    imageDescription.image = image
            })
        }

        deleteButton.setTitle(config.removeButtonTitle, for: .normal)
        deleteButton.tintColor = config.removeButtonColor
        deleteButton.tag = imageDescription.hashValue
        deleteButton.addControlEvent(.touchUpInside, removeClosure)
    }
    
}
