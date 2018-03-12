import IGListKit

final class ImageDiffableWrapper {
    let imageDescriptor: FlaneurImageDescriptor

    init(imageDescriptor: FlaneurImageDescriptor) {
        self.imageDescriptor = imageDescriptor
    }
}

extension ImageDiffableWrapper: Equatable {
    static func == (lhs: ImageDiffableWrapper, rhs: ImageDiffableWrapper) -> Bool {
        return lhs.imageDescriptor == rhs.imageDescriptor
    }
}

extension ImageDiffableWrapper: Hashable {
    var hashValue: Int { return imageDescriptor.hashValue }
}

// MARK: - ListDiffable Protocol's conformance

/**
 Conforming to ListDiffable protocol so it can be diffed by IGListKit
 */
extension ImageDiffableWrapper: ListDiffable {
    /// Produce a unique identifier for each object
    ///
    /// - Returns: a unique identifier for each object
    func diffIdentifier() -> NSObjectProtocol {
        switch imageDescriptor {
        case .image(let image):
            return image
        case .url(let imageURL):
            return imageURL as NSURL
        case .phAsset(let asset):
            return asset
        }
    }

    /// Check if two objects of the same type are equal
    ///
    /// - Parameter object: The object with which it is compared
    /// - Returns: A Boolean value indicating whether or not the objects are equal
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? ImageDiffableWrapper else { return false }
        return self == object
    }
}
