import UIKit

public extension UIImage {
    /// Returns the data for the image in a decently-sized JPEG format.
    ///
    /// - Parameters:
    ///   - targetWidth: the target width of the image, defaults to 1125.0 ie the largest width displayable on an iPhone (iPhone X).
    ///   - jpegCompressionQuality: the JPEG compression quality, defaults to 0.6 after benchmarking results
    /// - Returns: the data to upload for the image.
    public func dataForUpload(targetWidth: CGFloat = 1125.0, jpegCompressionQuality: CGFloat = 0.6) -> Data? {
        let processor = PreUploadProcessor()
        guard let image = processor.resizeImage(self, targetWidth: targetWidth) else {
            return nil
        }
        return UIImageJPEGRepresentation(image, jpegCompressionQuality)
    }
}
