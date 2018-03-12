/// The Assets bundle inside a pod is hard to reach.
/// This is the gateway.
class BundleLoader {
    /// The assets bundle of the pod.
    static var assetsBundle: Bundle = {
        let podBundle = Bundle(for: BundleLoader.self)

        guard let bundleURL = podBundle.url(forResource: "FlaneurImagePicker", withExtension: "bundle") else {
            fatalError("Cannot locate assets bundle")
        }

        guard let assetsBundle = Bundle(url: bundleURL) else {
            fatalError("Cannot create a bundle from URL")
        }

        return assetsBundle
    }()
}
