import CoreImage

/// A processor containing useful utils before uploading an image on a server.
public struct PreUploadProcessor {
    let context = CIContext()

    /// Creates a new processor.
    public init() {}

    /// Resizes an image to a target width using a Lanczos filter from Core Image.
    ///
    /// The returned image comes from a Core Graphics image version (as opposed to Core Image)
    /// so that it can also be compressed via `UIImageJPEGRepresentation` or `UIImagePNGRepresentation`.
    ///
    /// - Parameters:
    ///   - image: an image you want to resize.
    ///   - targetWidth: the target width of the returned image.
    /// - Returns: an image of the desired width if the resizing was successful, `nil` otherwise.
    public func resizeImage(_ image: UIImage, targetWidth: CGFloat) -> UIImage? {
        assert(targetWidth > 0.0)

        let scale = Double(targetWidth) / Double(image.size.width)

        guard let ciImage = CIImage(image: image) else {
            fatalError("Couldn't create CIImage from image in input")
        }

        guard let filter = CIFilter(name: "CILanczosScaleTransform") else {
            fatalError("The filter CILanczosScaleTransform is unavailable on this device.")
        }

        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(scale, forKey: kCIInputScaleKey)

        guard let result = filter.outputImage else {
            fatalError("No output on filter.")
        }

        guard let cgImage = context.createCGImage(result, from: result.extent) else {
            fatalError("Couldn't create CG Image")
        }

        return UIImage(cgImage: cgImage)
    }

    public func cheapResizeImage(_ image: UIImage, targetWidth: CGFloat) -> UIImage? {
        assert(targetWidth > 0.0)

        let targetHeight = CGFloat(Int(targetWidth * image.size.height / image.size.width))
        let targetSize = CGSize(width: targetWidth, height: targetHeight)
        let targetRect = CGRect(origin: .zero, size: targetSize)
        UIGraphicsBeginImageContext(targetSize)
        image.draw(in: targetRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
