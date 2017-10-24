//
//  ImageSourcesSectionController.swift
//  FlaneurImagePickerController
//
//  Created by Frenchapp on 14/07/2017.
//  
//

import UIKit
import IGListKit
import ActionKit

final class ImageSourcesSectionController: ListSectionController {

    private let config: FlaneurImagePickerConfig

    private var imageSource: FlaneurImageSource!

    private var buttonClosure: ActionKitControlClosure!

    init(with config: FlaneurImagePickerConfig, andButtonClosure buttonClosure: @escaping ActionKitControlClosure) {
        self.config = config
        self.buttonClosure = buttonClosure

        super.init()
    }

    override func sizeForItem(at index: Int) -> CGSize {
        let height = collectionContext!.containerSize.height
        let width: CGFloat = config.imageSourcesCellWidth  ?? collectionContext!.containerSize.width / CGFloat(config.imageSourcesArray.count)
        return CGSize(width: width, height: height)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: ImageSourcesCell.self, for: self, at: index) as? ImageSourcesCell else {
            fatalError()
        }
        cell.configure(with: imageSource, config: config, andButtonClosure: buttonClosure)

        return cell
    }

    override func didUpdate(to object: Any) {
        let source = object as! String

        imageSource = config.imageSourcesArray.filter { return $0.rawValue == source}[0]
    }
}
