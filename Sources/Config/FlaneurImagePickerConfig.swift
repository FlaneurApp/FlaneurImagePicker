//
//  FlaneurImagePickerConfig.swift
//  FlaneurImagePickerController
//
//  Created by Flâneur on 13/07/2017.
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
public class FlaneurImagePickerConfig {
    // MARK: - Source Selection

    /// Changes the order of the imageSources shown in the .imageSources section
    public var imageSourcesArray: [FlaneurImageSource] = [
        .library,
        .camera,
        .instagram
    ]

    /// Title displayed for the image source selection button.
    ///
    /// If `nil` and `imageForImageSource` is also `nil`, it defaults to `FlaneurImageSource.rawValue`.
    public var titleForImageSource: ((FlaneurImageSource) -> (String?)) = { imageSource in
        return nil
    }

    /// Image displayed for the image source selection button.
    public var imageForImageSource: ((FlaneurImageSource) -> (UIImage?)) = { _ in
        return nil
    }

    /// Title color for the image source selection buttons.
    ///
    /// Defaults to `.blue`.
    public var imageSourcesTitleColor: UIColor = .blue

    /// Background color for the image source selection buttons.
    ///
    /// Defaults to `.white`.
    public var imageSourcesBackgroundColor: UIColor = .white

    // MARK: - Titles
    
    /// The title of the remove button at the top right of the images picked
    public var removeButtonTitle: String = "Remove"
    

    // MARK: - Colors
    
    /// Background color for a specific collectionView in a section.
    ///
    /// Defaults to `.gray`.
    public var backgroundColorForSection: ((FlaneurImagePickerSection) -> (UIColor)) = { _ in
        return .gray
    }

    /// The color of the remove button
    public var removeButtonColor: UIColor?

    /// Color of the not selected dots of the pageControl
    public var pageControlTintColor: UIColor = .black
    
    /// Color of the currently selected dot of the pageControl
    public var pageControlCurrentIndexColor: UIColor = .white

    
    // MARK: - Content Size and shape
    
    /// Size of each thumbnail image shown in the .pickerView section, defaults to 1:4 of the screen's width
    public var sizeForImagesPickerView: ((CGSize) -> (CGSize)) = { collectionContextSize in
        return CGSize(width: UIScreen.main.bounds.width / 4, height: UIScreen.main.bounds.width / 4)
    }
    
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
