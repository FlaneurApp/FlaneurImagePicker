//
//  ImageSourcesCell.swift
//  FlaneurImagePickerController
//
//  Created by Flâneur on 14/07/2017.
//  
//

import UIKit

final class ImageSourcesCell: UICollectionViewCell {
    lazy internal var button: UIButton = {
        let view = UIButton(type: .custom)
        view.isUserInteractionEnabled = false
        self.contentView.addSubview(view)
        return view
    }()

    lazy internal var selectionBorder: UIView = {
        let view = UIView(frame: .zero)
        self.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 3.0).isActive = true
        view.backgroundColor = .black
        view.isHidden = true
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        button.frame = contentView.bounds
    }
    
    func configure(with imageSource: FlaneurImageSource,
                   config: FlaneurImagePickerConfig) {
        let image: UIImage? = config.imageForImageSource(imageSource)
        let title: String? = config.titleForImageSource(imageSource)

        if image == nil && title == nil {
            button.setImage(nil, for: .normal)
            button.setTitle(imageSource.rawValue, for: .normal)
        } else {
            button.setImage(image, for: .normal)
            button.setTitle(title, for: .normal)
        }

        button.setTitleColor(config.imageSourcesTitleColor, for: .normal)
        backgroundColor = config.imageSourcesBackgroundColor

        configureSelectionState()
    }

    override var isSelected: Bool {
        didSet {
            configureSelectionState()
        }
    }

    private func configureSelectionState() {
        selectionBorder.isHidden = !isSelected
    }
}
