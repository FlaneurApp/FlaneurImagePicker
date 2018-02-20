
//
//  FlaneurImageProvider.swift
//  FlaneurImagePickerController
//
//  Created by Flâneur on 24/07/2017.
//  
//

import UIKit

protocol FlaneurImageProviderDelegate: AnyObject {
    func didLoadImages(images: [FlaneurImageDescription])
    func didFailLoadingImages(with unauthorizedSourcePermission: FlaneurImageSource)
}

protocol FlaneurImageProvider {
    weak var delegate: FlaneurImageProviderDelegate? { get set }

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
