import CoreImage

func floor(_ size: CGSize) -> CGSize {
    return CGSize(width: floor(size.width), height: floor(size.height))
}

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
        let cgScale = CGFloat(scale)
        let targetSize = image.size.applying(CGAffineTransform(scaleX: cgScale, y: cgScale))
        let targetFrame = CGRect(origin: .zero, size: floor(targetSize))

        // We need to call `clampedToExtent` (and `cropped` further) to avoid edges artefacts
        // Cf. https://stackoverflow.com/questions/49147109/how-can-i-fix-a-core-images-cilanczosscaletransform-filter-border-artifact/49309714#49309714
        guard let ciImage = CIImage(image: image)?.clampedToExtent() else {
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

        guard let cgImage = context.createCGImage(result.cropped(to: targetFrame), from: targetFrame) else {
            fatalError("Couldn't create CG Image")
        }

        return UIImage(cgImage: cgImage)
    }

    /// Resizes an image to a target width using a basic Core Graphics rendering.
    ///
    /// - Parameters:
    ///   - image: an image you want to resize.
    ///   - targetWidth: the target width of the returned image.
    /// - Returns: an image of the desired width if the resizing was successful, `nil` otherwise.
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
