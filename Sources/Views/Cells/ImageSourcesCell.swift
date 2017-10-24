//
//  ImageSourcesCell.swift
//  FlaneurImagePickerController
//
//  Created by Frenchapp on 14/07/2017.
//  
//

import UIKit
import ActionKit

final class ImageSourcesCell: UICollectionViewCell {
    
    lazy private var button: UIButton = {
        let view = UIButton(type: .system)
        self.contentView.addSubview(view)
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        button.frame = contentView.bounds
    }
    
    func configure(with imageSource: FlaneurImageSource, config: FlaneurImagePickerConfig, andButtonClosure buttonClosure: @escaping ActionKitControlClosure) {
        
        let title = config.titleForImageSource?[imageSource] ?? imageSource.rawValue
        let titleColor = config.imageSourcesTitleColors?[imageSource] ?? .blue
        
        button.setTitle(title, for: .normal)
        button.tintColor = titleColor
        button.addControlEvent(.touchUpInside, buttonClosure)
        backgroundColor = config.imageSourcesBackgroundColor?[imageSource] ?? .white
    }
}
