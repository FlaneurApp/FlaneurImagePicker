//
//  AppDelegate.swift
//  FlaneurImagePickerController
//
//  Created by Flâneur on 11/07/2017.
//  
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // Set UIAppearance
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Futura-CondensedMedium", size: 14.0)!],
                                                      for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Futura-CondensedMedium", size: 14.0)!],
                                                            for: .highlighted)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Futura-CondensedMedium", size: 14.0)!],
                                                            for: .disabled)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Futura-CondensedMedium", size: 14.0)!],
                                                            for: .selected)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Futura-CondensedMedium", size: 14.0)!],
                                                            for: .focused)

        return true
    }

}

