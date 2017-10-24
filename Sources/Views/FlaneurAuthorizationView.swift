//
//  FlaneurAuthorizationView.swift
//  FlaneurImagePickerController
//
//  Created by Frenchapp on 28/07/2017.
//  
//

import UIKit
import ActionKit

/// Inherit from this protocol and UIView in order to provide a custom authorization view (Views displayed
/// instead of pickerView when source is not allowed already. You need to include ActionKit in order to work
/// with the mandatory **authorizeClosure** which is of type *ActionKitVoidClosure*
public protocol FlaneurAuthorizationView {
    /// Init with sourceName et authorizeClosure
    ///
    /// - Parameters:
    ///   - sourceName: The name of the source (ex: Instagram) will be given to you through this parameter
    ///   - closure: The closure to attach to your UIButton in order to launch the authorization popup, you need to include ActionKit in order to do that.[linked text](https://github.com/ActionKit/ActionKit)
    init(withSourceName sourceName: String, authorizeClosure closure: @escaping ActionKitVoidClosure)
}

class FlaneurAuthorizationDefaultView: UIView, FlaneurAuthorizationView {

    var imageView = UIImageView()
    var label = UILabel()
    var authorizeButton = UIButton(type: .system)
    
    let kButtonSize = CGSize(width: 200, height: 50)
    
    required init(withSourceName sourceName: String, authorizeClosure closure: @escaping ActionKitVoidClosure) {
        super.init(frame: .zero)
        
        self.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
        
        let podBundle = Bundle(for: self.classForCoder)
        if let bundleURL = podBundle.url(forResource: "FlaneurImagePicker", withExtension: "bundle") {
            if let bundle = Bundle(url: bundleURL) {
                if let image = UIImage(named: "flaneur_logo.png", in: bundle, compatibleWith: nil) {
                    imageView.image = image
                    imageView.contentMode = .scaleAspectFit
                }
            }
        }
    
        authorizeButton.backgroundColor = .black
        authorizeButton.tintColor = .white
        authorizeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        authorizeButton.setTitle(NSLocalizedString("AUTHORIZE ACCESS", comment: ""), for: .normal)
        authorizeButton.addControlEvent(.touchUpInside, closure)
        
        label.text = NSLocalizedString("Authorize Flâneur to access to \(sourceName)", comment: "")
        
        addSubview(imageView)
        addSubview(label)
        addSubview(authorizeButton)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

        authorizeButton.translatesAutoresizingMaskIntoConstraints = false
        authorizeButton.widthAnchor.constraint(equalToConstant: kButtonSize.width).isActive = true
        authorizeButton.heightAnchor.constraint(equalToConstant: kButtonSize.height).isActive = true
        authorizeButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        authorizeButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 25).isActive = true
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -20).isActive = true

    }

}
