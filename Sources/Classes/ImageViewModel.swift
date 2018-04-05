import Photos

class ImageViewModel {
    weak var imageView: UIImageView?

    var thumbnailMode: Bool = false
    var cancelFetch: (() -> ())? = { }

    init(imageView: UIImageView) {
        debugPrint("init")
        self.imageView = imageView
    }

    deinit {
        debugPrint("deinit")
    }

    func prepareForReuse() {
        debugPrint("prepareForReuse")
        if imageView?.image == nil {
            cancelFetch?()
        }
        imageView?.image = nil
    }

    func setImage(with descriptor: ImageDescriptor) {
        cancelFetch = descriptor.displayImage(in: imageView)
    }
}

protocol ImageDescriptor {
    func displayImage(in imageView: UIImageView?) -> (() -> ())?
}

extension FlaneurImageDescriptor: ImageDescriptor {
    func displayImage(in imageView: UIImageView?)  -> (() -> ())? {
        guard let imageView = imageView else { return {} }

        switch(self) {
        case .url(let url):
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: url)

            func cancel() {
                imageView.kf.cancelDownloadTask()
            }

            return cancel
        case .image(let image):
            imageView.image = image
            return {}
        case .phAsset(let asset):
            let requestID = imageView.setImageFromPHAsset(asset: asset, thumbnail: false, deliveryMode: .opportunistic, completion: nil)
            func cancel() {
                PHImageManager.default().cancelImageRequest(requestID)
            }
            return cancel
        }
    }
}
