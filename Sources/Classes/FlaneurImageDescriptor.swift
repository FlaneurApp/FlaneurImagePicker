import Photos
import Kingfisher

/// Descriptor of an image resource.
public enum FlaneurImageDescriptor {
    /// The image is stored remotely and accessible via a URL.
    case url(_: URL)

    /// The image is in-memory (via a `UIImage` instance).
    case image(_: UIImage)

    /// The image is part of the user's Photos library.
    case phAsset(_: PHAsset)
}

extension FlaneurImageDescriptor: Hashable {
    public var hashValue: Int {
        switch self {
        case .url(let imageURL):
            return imageURL.hashValue
        case .image(let image):
            return image.hashValue
        case .phAsset(let asset):
            return asset.hashValue
        }
    }
}

extension FlaneurImageDescriptor: Equatable {
    static public func == (lhs: FlaneurImageDescriptor, rhs: FlaneurImageDescriptor) -> Bool {
        switch (lhs, rhs) {
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

extension FlaneurImageDescriptor: CustomStringConvertible {
    public var description: String {
        switch self {
        case .url(let imageURL):
            return "Image.url(\(imageURL))"
        case .image(let image):
            return "Image.image(\(image))"
        case .phAsset(let asset):
            return "Image.phAsset(\(asset))"
        }
    }
}

extension FlaneurImageDescriptor {
    /// Fetches the images described by the instance.
    ///
    /// The handler will be called synchronously or asynchronously depending on the nature of `self`.
    ///
    /// - Parameter resultHandler: the handler that is called with either an image or an error.
    public func fetchImage(resultHandler: @escaping (UIImage?, Error?) -> ()) -> () {
        switch self {
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
