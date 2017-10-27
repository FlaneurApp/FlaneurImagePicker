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
    lazy var imageView: FlaneurImageView = {
        let view = FlaneurImageView()
        view.backgroundColor = .black
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.assetThumbnailMode = true
        self.contentView.addSubview(view)
        return view
    }()
    
    private weak var imageDescription: FlaneurImageDescription!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }
    
    override func prepareForReuse() {
        imageView.prepareForReuse()
        super.prepareForReuse()
    }
    
    func configure(with config: FlaneurImagePickerConfig,
                   andImageDescription imageDescription: FlaneurImageDescription) {
        self.imageDescription = imageDescription
        self.imageView.setImage(with: imageDescription)
    }
}
