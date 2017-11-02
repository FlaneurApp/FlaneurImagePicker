//
//  TestView.swift
//  FlaneurImagePickerController
//
//  Created by Flâneur on 01/08/2017.
//  
//

import UIKit
import ActionKit
import FlaneurImagePicker

class TestView: UIView, FlaneurAuthorizationView {

    var button = UIButton(type: .system)
    
    required init(withSourceName sourceName: String, authorizeClosure closure: @escaping ActionKitVoidClosure) {
        super.init(frame: .zero)
        
        backgroundColor = .red
        
        button.setTitle("Autoriser \(sourceName)", for: .normal)
        button.addControlEvent(.touchUpInside, closure)
        
        self.addSubview(button)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
}
