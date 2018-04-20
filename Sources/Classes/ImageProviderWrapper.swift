import IGListKit

final class ImageProviderWrapper: ListDiffable {
    let imageProvider: FlaneurImageProvider

    init(_ imageProvider: FlaneurImageProvider) {
        self.imageProvider = imageProvider
    }

    func diffIdentifier() -> NSObjectProtocol {
        return NSString(string: imageProvider.name)
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let otherObject = object as? ImageProviderWrapper else { return false }
        return imageProvider.name == otherObject.imageProvider.name
    }
}

