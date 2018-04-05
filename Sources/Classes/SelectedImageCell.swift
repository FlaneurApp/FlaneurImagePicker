//
//  SelectedImageCell.swift
//  FlaneurImagePickerController
//
//  Created by Flâneur on 14/07/2017.
//  
//

import UIKit
import ActionKit

final class SelectedImageCell: UICollectionViewCell {
    private let gridUnit: CGFloat = 8.0

    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.vm.thumbnailMode = false
        self.contentView.addSubview(view)
        return view
    }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        self.contentView.insertSubview(button, aboveSubview: self.imageView)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        // This is the FontAwesome trash
        deleteButton.setTitle("\u{f2ed}", for: .normal)
        deleteButton.titleLabel?.font = UIFont(name: "FontAwesome5FreeRegular", size: 2.0 * gridUnit)
        deleteButton.tintColor = .white
        deleteButton.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
        deleteButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.3).cgColor
        deleteButton.layer.borderWidth = 1.0
        deleteButton.layer.cornerRadius = 2.0 * gridUnit
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            deleteButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -gridUnit),
            deleteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -gridUnit),
            deleteButton.heightAnchor.constraint(equalToConstant: 4*gridUnit),
            deleteButton.widthAnchor.constraint(equalToConstant: 4*gridUnit),
            ])
    }

    override func prepareForReuse() {
        imageView.vm.prepareForReuse()
        super.prepareForReuse()
    }

    func configure(with imageDescription: FlaneurImageDescriptor!,
                   config: FlaneurImagePickerConfig,
                   andRemoveClosure removeClosure: @escaping ActionKitControlClosure) {
        imageView.contentMode = config.selectedImagesContentMode
        imageView.vm.setImage(with: imageDescription)

        deleteButton.tag = imageDescription.hashValue
        deleteButton.addControlEvent(.touchUpInside, removeClosure)
    }
}
