//
//  FlaneurImageDescription.swift
//  FlaneurImagePickerController
//
//  Created by Frenchapp on 12/07/2017.
//  
//

import UIKit
import IGListKit
import Photos


/// Defines whether a FlaneurImageDescription is accessible
/// via the "imageURL", the "image" or the "associatedPHAsset" property
public enum FlaneurImageDescriptionSourceType {
    /// It means that the image is set via the **imageURL** property and is of URL type
    case urlBased
    /// It means that the image is set via the **image** property and is of UIImage type
    case imageBased
    /// It means that the image is set via the **associatedPHAsset** property and is of PHAsset type
    case phassetBased
}

/**
    FlaneurImageDescription is a model used to store an image.
    The image can either be defined by an URL, a PHAsset or an actuel UIImage.
 */
final public class FlaneurImageDescription: NSObject {
    
    // MARK: - Properties

    /// Url of the image contained in the description.
    /// It can be null but an **image** or an **associatedPHAsset** should be set in this case
    public var imageURL: URL! {
        didSet {
            self.imageSource = .urlBased
        }
    }
    
    /// The image contained in the description.
    /// It can be null but an **imageURL** or an **associatedPHAsset** should be set in this case
    public var image: UIImage! {
        didSet {
            if self.imageSource == nil || self.imageSource != .phassetBased {
                self.imageSource = .imageBased
            }
        }
    }
    
    /// The PHAsset contained in the description.
    /// It can be null but an **imageURL** or an **image** should be set in this case
    public var associatedPHAsset: PHAsset! {
        didSet {
            self.imageSource = .phassetBased
        }
    }
    
    /// Depending on the type, an image can be accessed through the
    /// **imageURL** property, the **associatedPHAsset** property (by fetching it first), or the **image** property
    public var imageSource: FlaneurImageDescriptionSourceType!
    
    
    
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
        super.init()
        ({ self.imageURL = imageURL })()
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
        super.init()
        ({ self.image = image })()
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
        super.init()
        ({ self.associatedPHAsset = asset })()
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
extension FlaneurImageDescription {
    /// A unique identifier for each object
    override public var hashValue: Int {
        switch imageSource! {
        case .urlBased:
            return imageURL.absoluteString.hashValue
        case .imageBased:
            return image.hashValue
        case .phassetBased:
            return associatedPHAsset.hashValue
        }
    }
    
    /// Overloads the operator **==** to compare two objects of the FlaneurImageDescription's type
    ///
    /// - Parameters:
    ///   - object: Object at the right of the operand '=='
    /// - Returns: A boolean value indicating whether or not the two objects are equal
    override public func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? FlaneurImageDescription,
            self.imageSource == other.imageSource else {
            return false
        }
        switch other.imageSource! {
        case .urlBased:
            return self.imageURL.absoluteString.hashValue == other.imageURL.absoluteString.hashValue
        case .imageBased:
            return UIImagePNGRepresentation(self.image) == UIImagePNGRepresentation(other.image)
        case .phassetBased:
            return self.associatedPHAsset.hashValue == other.associatedPHAsset.hashValue
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
        return hashValue as NSObjectProtocol
    }
    
    /// Check if two objects of the same type are equal
    ///
    /// - Parameter object: The object with which it is compared
    /// - Returns: A Boolean value indicating whether or not the objects are equal
    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard self !== object else { return true }
        guard let object = object as? FlaneurImageDescription else { return false }
        return object.hashValue == hashValue
    }
}
