//
//  PickedImagesViewerSectionController.swift
//  FlaneurImagePickerController
//
//  Created by Flâneur on 14/07/2017.
//  
//

import UIKit
import IGListKit
import Kingfisher
import ActionKit

/// This is the `IGListKit` section controller for the **selected images** part of the
/// `FlaneurImagePickerController`.
final class SelectedImagesViewerSectionController: ListSectionController {
    private let config: FlaneurImagePickerConfig
    private var imageDescription: FlaneurImageDescription!
    private var removeButtonClosure: ActionKitControlClosure!
    
    init(with config: FlaneurImagePickerConfig,
         andRemoveButtonClosure removeButtonClosure: @escaping ActionKitControlClosure) {
        self.config = config
        self.removeButtonClosure = removeButtonClosure

        super.init()
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        let height = collectionContext!.containerSize.height - inset.top - inset.bottom
        let width = collectionContext!.containerSize.width - inset.left - inset.right
        return CGSize(width: width, height: height)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: SelectedImageCell.self, for: self, at: index) as? SelectedImageCell else {
            fatalError()
        }
                        
        cell.configure(with: imageDescription, config: config, andRemoveClosure: removeButtonClosure)
        
        return cell
    }
    
    override func didUpdate(to object: Any) {
        imageDescription = object as! FlaneurImageDescription
    }
}
