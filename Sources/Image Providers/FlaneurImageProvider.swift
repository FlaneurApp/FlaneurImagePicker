
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
    weak var delegate: FlaneurImageProviderDelegate? {get set}
    weak var parentVC: UIViewController? {get set}    
    
    init(delegate: FlaneurImageProviderDelegate, andParentVC parentVC: UIViewController)
    
    func isAuthorized() -> Bool

    func askForPermission(isPermissionGiven: @escaping (Bool) -> Void)
    
    func fetchImagesFromSource()
    
    func fetchNextPage()
}
