//
//  PickerCell.swift
//  FlaneurImagePickerController
//
//  Created by Flâneur on 14/07/2017.
//  
//

import UIKit
import Photos

final class PickerCell: UICollectionViewCell {
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .black
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.vm.thumbnailMode = true
        self.contentView.addSubview(view)
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }
    
    override func prepareForReuse() {
        imageView.vm.prepareForReuse()
        super.prepareForReuse()
    }
    
    func configure(with config: FlaneurImagePickerConfig,
                   andImageDescription imageDescription: FlaneurImageDescriptor) {
        imageView.vm.setImage(with: imageDescription)
    }
}
