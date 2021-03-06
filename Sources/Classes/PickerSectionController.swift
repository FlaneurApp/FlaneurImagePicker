//
//  PickerSectionController.swift
//  FlaneurImagePickerController
//
//  Created by Flâneur on 14/07/2017.
//  
//

import UIKit
import IGListKit
import Kingfisher

typealias ImageSelectionClosure = (FlaneurImageDescriptor) -> Void

final class PickerSectionController: ListSectionController {
    private let config: FlaneurImagePickerConfig
    private weak var imageDescription: ImageDiffableWrapper!
    private var onImageSelectionClosure: ImageSelectionClosure!
    
    init(with config: FlaneurImagePickerConfig,
         andImageSelectedClosure onImageSelectionClosure: @escaping ImageSelectionClosure) {
        self.config = config
        self.onImageSelectionClosure = onImageSelectionClosure
        
        super.init()
        self.inset = config.paddingForImagesPickerView ?? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func sizeWithPadding(width: CGFloat, height: CGFloat, padding: UIEdgeInsets) -> CGSize {
        let finalWidth = width - padding.left - padding.right
        let finalHeight = height - padding.top - padding.bottom
        return CGSize(width: finalWidth, height: finalHeight)
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        let customSize = config.sizeForImagesPickerView(collectionContext!.containerSize)
        return sizeWithPadding(width: customSize.width,
                               height: customSize.height,
                               padding: self.inset)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: PickerCell.self, for: self, at: index) as? PickerCell else {
            fatalError()
        }
        
        cell.configure(with: config, andImageDescription: imageDescription.imageDescriptor)

        return cell
    }
    
    override func didUpdate(to object: Any) {
        precondition(object is ImageDiffableWrapper)
        imageDescription = object as! ImageDiffableWrapper
    }
    
    override func didSelectItem(at index: Int) {
        onImageSelectionClosure(imageDescription.imageDescriptor)
    }
    
}

