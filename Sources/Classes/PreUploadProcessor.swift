import CoreImage

public struct PreUploadProcessor {
    let context = CIContext()

    public init() {}

    public func resizeImage(_ image: UIImage, targetWidth: CGFloat) -> UIImage? {
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

    public func cheapResize(_ image: UIImage, targetWidth: CGFloat) -> UIImage? {
        
    }
}
