//
//  FlaneurImageDescription.swift
//  FlaneurImagePickerController
//
//  Created by Flâneur on 12/07/2017.
//  
//

import UIKit
import IGListKit
import Photos
import Kingfisher


/// Defines whether a FlaneurImageDescription is accessible
/// via the "imageURL", the "image" or the "associatedPHAsset" property
public enum FlaneurImageDescriptionSourceType {
    /// It means that the image is set via the **imageURL** property and is of URL type
    case url(_: URL)

    /// It means that the image is set via the **image** property and is of UIImage type
    case image(_: UIImage)

    /// It means that the image is set via the **associatedPHAsset** property and is of PHAsset type
    case phAsset(_: PHAsset)
}

/**
 FlaneurImageDescription is a model used to store an image.
 The image can either be defined by an URL, a PHAsset or an actuel UIImage.
 */
final public class FlaneurImageDescription {
    
    // MARK: - Properties

    /// The source of the image.
    public var sourceType: FlaneurImageDescriptionSourceType
    
    // MARK: - Initializers methods
    
    /**
     Init with a URL
     
     - Parameter imageURL: A URL pointing on the image with which you want to initialize the FlaneurImageDescription
     
     - returns: A new FlaneurImageDescription
     */
    public init?(imageURL: URL?) {
        // Check that imageURL is not nil
        guard let imageURL = imageURL else {
            return nil
        }

        self.sourceType = .url(imageURL)
    }
    
    
    /**
     Init with a UIImage
     
     - Parameter image: An image with which you want to initialize the FlaneurImageDescription
     
     - returns: A new FlaneurImageDescription
     */
    public init?(image: UIImage?) {
        guard let image = image else {
            return nil
        }

        self.sourceType = .image(image)
    }
    
    /**
     Init with a PHAsset
     
     - Parameter asset: An asset referencing the image with which you want to initialize the FlaneurImageDescription
     
     - returns: A new FlaneurImageDescription
     */
    public init?(asset: PHAsset?) {
        guard let asset = asset else {
            return nil
        }

        self.sourceType = .phAsset(asset)
    }
    
    /**
     Init with a URL String
     
     - Parameter imageURLString: A string representing the URL pointing on the image with which you want to initialize the FlaneurImageDescription
     
     - returns: A new FlaneurImageDescription
     */
    public convenience init?(imageURLString: String?) {
        guard let imageURLString = imageURLString else {
            return nil
        }
        self.init(imageURL: URL(string: imageURLString))
    }
    
}

// MARK: - Hashable Protocol's conformance

/**
 Conforming to Hashable protocol so it can be ListDiffable
 */
extension FlaneurImageDescription: Equatable {
    static public func == (lhs: FlaneurImageDescription, rhs: FlaneurImageDescription) -> Bool {
        switch (lhs.sourceType, rhs.sourceType) {
        case (.url(let imageURL1), .url(let imageURL2)):
            return imageURL1 == imageURL2
        case (.image(let image1), .image(let image2)):
            return image1 == image2
        case (.phAsset(let asset1), .phAsset(let asset2)):
            return asset1 == asset2
        default:
            return false
        }
    }
}

extension FlaneurImageDescription: Hashable {
    public var hashValue: Int {
        switch sourceType {
        case .url(let imageURL):
            return imageURL.hashValue
        case .image(let image):
            return image.hashValue
        case .phAsset(let asset):
            return asset.hashValue
        }
    }
}

// MARK: - ListDiffable Protocol's conformance

/**
 Conforming to ListDiffable protocol so it can be diffed by IGListKit
 */
extension FlaneurImageDescription: ListDiffable {
    /// Produce a unique identifier for each object
    ///
    /// - Returns: a unique identifier for each object
    public func diffIdentifier() -> NSObjectProtocol {
        switch sourceType {
        case .image(let image):
            return image
        case .url(let imageURL):
            return NSString(string: imageURL.absoluteString)
        case .phAsset(let asset):
            return asset
        }
    }
    
    /// Check if two objects of the same type are equal
    ///
    /// - Parameter object: The object with which it is compared
    /// - Returns: A Boolean value indicating whether or not the objects are equal
    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? FlaneurImageDescription else { return false }

        return self == object
    }
}

extension FlaneurImageDescription: CustomStringConvertible {
    public var description: String {
        switch sourceType {
        case .url(let imageURL):
            return "Image.url(\(imageURL))"
        case .image(let image):
            return "Image.image(\(image))"
        case .phAsset(let asset):
            return "Image.phAsset(\(asset))"
        }
    }
}

extension FlaneurImageDescription {
    public func requestImage(resultHandler: @escaping(UIImage?, Error?) -> ()) -> () {
        switch sourceType {
        case .url(let imageURL):
            ImageDownloader.default.downloadImage(with: imageURL,
                                                  completionHandler: { image, error, url, data in
                                                    resultHandler(image, error)
            })
        case .image(let image):
            resultHandler(image, nil)
        case .phAsset(let asset):
            let size = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
            _ = asset.requestImage(targetSize: size,
                                   deliveryMode: .highQualityFormat,
                                   resultHandler: resultHandler)
        }
    }
}
