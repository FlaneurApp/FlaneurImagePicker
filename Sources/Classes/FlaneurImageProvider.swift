
//
//  FlaneurImageProvider.swift
//  FlaneurImagePickerController
//
//  Created by Flâneur on 24/07/2017.
//  
//

import UIKit

public protocol FlaneurImageProviderDelegate: AnyObject {
    func presentingViewController(for: FlaneurImageProvider) -> UIViewController
    func imageProvider(_: FlaneurImageProvider, didLoadImages: [FlaneurImageDescriptor])
    func imageProvider(_: FlaneurImageProvider, didFailWithError: Error)
}

public protocol FlaneurImageProvider {
    var name: String { get }

    var delegate: FlaneurImageProviderDelegate? { get set }

    /// Whether or not the image provider's source is currently authorized.
    ///
    /// - Returns: `true` if authorized, `false` otherwise.
    func isAuthorized() -> Bool

    /// Requests the user’s permission for accessing the image provider's source.
    ///
    /// - Parameter handler: A block called once the user answered the request.
    func requestAuthorization(_ handler: @escaping (Bool) -> Void)

    func fetchImagesFromSource()

    func fetchNextPage()
}
