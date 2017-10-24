//
//  FlaneurImagePickerNavigationBar.swift
//  FlaneurImagePickerController
//
//  Created by Frenchapp on 14/07/2017.
//  
//

import UIKit
import ActionKit

final class FlaneurImagePickerNavigationBar: UINavigationBar {
    
    init(with config: FlaneurImagePickerConfig, cancelButtonClosure: @escaping ActionKitBarButtonItemClosure, doneButtonClosure: @escaping ActionKitBarButtonItemClosure) {
        super.init(frame: .zero)
        configure(with: config, cancelButtonClosure: cancelButtonClosure, doneButtonClosure: doneButtonClosure)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with config: FlaneurImagePickerConfig, cancelButtonClosure: @escaping ActionKitBarButtonItemClosure, doneButtonClosure: @escaping ActionKitBarButtonItemClosure) {
        let navItem = UINavigationItem(title: config.navBarTitle)
        
        let cancelButton = UIBarButtonItem(title: config.cancelButtonTitle, style: .done, actionClosure: cancelButtonClosure)
        cancelButton.tintColor = config.cancelButtonColor
        
        let doneButton = UIBarButtonItem(title: config.doneButtonTitle, style: .done, actionClosure: doneButtonClosure)
        doneButton.tintColor = config.doneButtonColor
        
        navItem.leftBarButtonItem = cancelButton
        navItem.rightBarButtonItem = doneButton
        
        
        self.barTintColor = config.navBarBackgroundColor
        if let navBarTitleColor = config.navBarTitleColor {
            self.titleTextAttributes = [NSForegroundColorAttributeName: navBarTitleColor]
        }
        
        self.pushItem(navItem, animated: true)
    }
}
