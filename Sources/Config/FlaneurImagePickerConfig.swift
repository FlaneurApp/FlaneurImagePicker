//
//  FlaneurImagePickerConfig.swift
//  FlaneurImagePickerController
//
//  Created by Frenchapp on 13/07/2017.
//  
//

import UIKit

/// Used to reference an image source
public enum FlaneurImageSource: String {
    /// User's camera source, needs "Privacy - Camera Usage Description" set in info.plist
    case camera
    /// User's library source, needs "Privacy - Photo Library Usage Description" set in info.plist
    case library
    /// User's intagram source, needs "InstagramClientID" and "InstagramRedirectURI" set in info.plist
    case instagram
}

/// Used to reference a section into the Image Picker
public enum FlaneurImagePickerSection {
    /// Section where selected images go, top section by default
    case selectedImages
    /// Section allowing the user to select an image source, middle section by default
    case imageSources
    /// Section showing the pictures of the currently selected image source, bottom section by default
    case pickerView
}

/// An object used to set all the configurations relative to the FlaneurImagePicker
public struct FlaneurImagePickerConfig {
    
    // MARK: - Titles
    
    /// The title of the navigation bar
    public var navBarTitle: String = "My Image Picker"
    
    /// The title of the cancel button at the top left of the picker
    public var cancelButtonTitle: String = "Cancel"
    
    /// The title of the done button at the top right of the picker
    public var doneButtonTitle: String = "Done"
    
    /// The title of the remove button at the top right of the images picked
    public var removeButtonTitle: String = "Remove"
    
    /// Title shown for a specific image source, defaults to enum FlaneurImageSource.rawValue
    public var titleForImageSource: [FlaneurImageSource: String]?
    
    
    
    // MARK: - Colors
    
    /// The background color of the navigation bar
    public var navBarBackgroundColor: UIColor?
    /// The color of the navigation bar's title
    public var navBarTitleColor: UIColor?

    /// The color of the cancel button
    public var cancelButtonColor: UIColor?
    /// The color of the done button
    public var doneButtonColor: UIColor?
    
    /// The color of the remove button
    public var removeButtonColor: UIColor?
    
    /// Title color for a specific image source, defaults to .blue
    public var imageSourcesTitleColors: [FlaneurImageSource: UIColor]?
    
    /// BackgroundColor for a specific image source, defaults to .white
    public var imageSourcesBackgroundColor: [FlaneurImageSource: UIColor]?


    /// BackgroundColor for a specific collectionView in a section, defaults to .black
    public var backgroundColorForSection: [FlaneurImagePickerSection: UIColor]?
    
    /// Color of the not selected dots of the pageControl
    public var pageControlTintColor: UIColor = .black
    
    /// Color of the currently selected dot of the pageControl
    public var pageControlCurrentIndexColor: UIColor = .white
    
    
    
    // MARK: - Content Size and shape
    
    /// Size of each thumbnail image shown in the .pickerView section, defaults to 1:4 of the screen's width
    public var sizeForImagesPickerView: CGSize = CGSize(width: UIScreen.main.bounds.width / 4, height: UIScreen.main.bounds.width / 4)
    
    /// Padding for each image shown in the .pickerView section, defaults to 0
    public var paddingForImagesPickerView: UIEdgeInsets?
    
    /// Size of each image source's cell shown in the .imageSources section, defaults to the screen's width divided by the total number
    /// of image sources so that the width of the screen can contain them all
    public var imageSourcesCellWidth: CGFloat?

    /// Content Mode for images in the .selectedImages section, defaults to .scaleAspectFill
    public var selectedImagesContentMode: UIViewContentMode = .scaleAspectFill
    
    // MARK: - Sections configurations
    
    /// Maximum number of selected images, defaults to 5
    public var maxNumberOfSelectedImages = 5
    
    /// Changes the order of the sections shown on the screen
    public var sectionsOrderArray: [FlaneurImagePickerSection] = [
        .selectedImages,
        .imageSources,
        .pickerView
    ]
    
    /// Changes the order of the imageSources shown in the .imageSources section
    public var imageSourcesArray: [FlaneurImageSource] = [
        .library,
        .camera,
        .instagram
    ]
    
    
    // MARK: - Views
    
    /// Class of the custom view to use for authorization view.
    /// # IMPORTANT
    /// ### **Your class must conform to the FlaneurAuthorizationView's Protocol**
    public var authorizationViewCustomClass: UIView.Type?
    
    
    // MARK: - Behavior shifters
    
    /// A closure to call when the maximum number of selected pictures is reached, defaults to a UIAlertViewController
    public var maxNumberOfSelectedImagesReachedClosure: (UIViewController?) -> Void = { callerViewController in
        guard let vc = callerViewController else {
            return
        }
        let alert = UIAlertController(
            title: NSLocalizedString("Alert", comment: ""),
            message: NSLocalizedString("Maximum number of pictures reached", comment: ""),
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("OK", comment: ""),
            style: .cancel,
            handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
}
