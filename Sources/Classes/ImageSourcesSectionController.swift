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
    private let numberOfSources: Int
    private var providerWrapper: ImageProviderWrapper?
    private var selectHandler: ActionKitVoidClosure

    init(with config: FlaneurImagePickerConfig,
         numberOfSources: Int,
         andSelectHandler selectHandler: @escaping ActionKitVoidClosure) {
        self.config = config
        self.numberOfSources = numberOfSources
        self.selectHandler = selectHandler

        super.init()
    }

    override func sizeForItem(at index: Int) -> CGSize {
        let height = collectionContext!.containerSize.height
        let width: CGFloat = config.imageSourcesCellWidth ?? collectionContext!.containerSize.width / CGFloat(numberOfSources)
        return CGSize(width: width, height: height)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let provider = providerWrapper?.imageProvider else { fatalError("no provider set") }
        guard let cell = collectionContext?.dequeueReusableCell(of: ImageSourcesCell.self,
                                                                for: self, at: index) as? ImageSourcesCell
            else {
            fatalError()
        }
        cell.configure(with: provider, config: config)
        return cell
    }

    override func didUpdate(to object: Any) {
        precondition(object is ImageProviderWrapper)
        self.providerWrapper = object as? ImageProviderWrapper
    }

    override func didSelectItem(at index: Int) {
        selectHandler()
    }
}
