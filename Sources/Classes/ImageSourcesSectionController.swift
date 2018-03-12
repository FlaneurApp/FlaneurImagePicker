//
//  ImageSourcesSectionController.swift
//  FlaneurImagePickerController
//
//  Created by Flâneur on 14/07/2017.
//  
//

import UIKit
import IGListKit
import ActionKit

final class ImageSourcesSectionController: ListSectionController {
    private let config: FlaneurImagePickerConfig
    private var imageSource: FlaneurImageSource?
    private var selectHandler: ActionKitVoidClosure

    init(with config: FlaneurImagePickerConfig,
         andSelectHandler selectHandler: @escaping ActionKitVoidClosure) {
        self.config = config
        self.selectHandler = selectHandler

        super.init()
    }

    override func sizeForItem(at index: Int) -> CGSize {
        let height = collectionContext!.containerSize.height
        let width: CGFloat = config.imageSourcesCellWidth  ?? collectionContext!.containerSize.width / CGFloat(config.imageSourcesArray.count)
        return CGSize(width: width, height: height)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard imageSource != nil else { fatalError("no image source") }
        guard let cell = collectionContext?.dequeueReusableCell(of: ImageSourcesCell.self,
                                                                for: self, at: index) as? ImageSourcesCell
            else {
            fatalError()
        }
        cell.configure(with: imageSource!,
                       config: config)

        return cell
    }

    override func didUpdate(to object: Any) {
        precondition(object is String)
        let source = object as! String
        imageSource = FlaneurImageSource(rawValue: source)
    }

    override func didSelectItem(at index: Int) {
        selectHandler()
    }
}
