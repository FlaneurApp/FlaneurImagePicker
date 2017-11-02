//
//  ViewController.swift
//  FlaneurImagePickerController
//
//  Created by Flâneur on 11/07/2017.
//  
//

import UIKit
import FlaneurImagePicker

class FullWidthNavigationItemTitle: UIView {
    weak var containingView: UIView?

    var titleLabel: UILabel? {
        didSet {
            guard titleLabel != nil else { return }
            self.addSubview(titleLabel!)
        }
    }

    override func layoutSubviews() {
        guard let referenceHeight = self.containingView?.frame.height else { return }

        if self.frame.height != referenceHeight {
            self.frame = CGRect(x: self.frame.origin.x,
                                y: self.frame.origin.y,
                                width: self.frame.width,
                                height: referenceHeight)
        }

        self.titleLabel?.frame = CGRect(x: 16.0,
                                        y: 0.0,
                                        width: self.frame.width - 16.0,
                                        height: referenceHeight)
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func lauchPickerButtonTouched() {
        let images =  [
            FlaneurImageDescription(imageURLString: "https://cdn.pixabay.com/photo/2017/07/24/02/40/pink-roses-2533389_960_720.jpg")!,
            FlaneurImageDescription(imageURLString: "https://cdn.pixabay.com/photo/2017/04/04/14/24/turtle-2201433_960_720.jpg")!,
            FlaneurImageDescription(imageURLString: "https://cdn.pixabay.com/photo/2017/07/28/16/30/bee-pollen-2549125_960_720.jpg")!
        ]
        
        let flaneurPicker = FlaneurImagePickerController(maxNumberOfSelectedImages: 6,
                                                         userInfo: nil,
                                                         sourcesDelegate: [],
                                                         selectedImages: images)

        flaneurPicker.view.backgroundColor = .red

        // Customization of the navigation bar.
        flaneurPicker.navigationBar.barTintColor = .red
        flaneurPicker.navigationBar.isTranslucent = false
        flaneurPicker.navigationBar.topItem?.backBarButtonItem?.title = "MyCancel"
        flaneurPicker.navigationBar.topItem?.backBarButtonItem?.tintColor = .blue
        flaneurPicker.navigationBar.topItem?.rightBarButtonItem?.title = "MySave"
        flaneurPicker.navigationBar.topItem?.rightBarButtonItem?.tintColor = .green
        flaneurPicker.navigationBar.topItem?.title = "MyTitle"
        flaneurPicker.navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "Futura-CondensedMedium", size: 16.0)!,
            NSForegroundColorAttributeName: UIColor.cyan
        ]

        // For an event uglier customization of the navigation bar, uncomment this:
        //        let myTitleViewContainer = FullWidthNavigationItemTitle(frame: CGRect(x: 0.0, y: 0.0, width: 1000.0, height: 0.0))
        //        myTitleViewContainer.containingView = flaneurPicker.navigationBar
        //        let myTitleText = UILabel(frame: .zero)
        //        myTitleText.numberOfLines = 1
        //        myTitleText.text = "Add your pictures".uppercased()
        //        myTitleText.font = UIFont(name: "Futura-CondensedMedium", size: 16.0)!
        //        myTitleText.backgroundColor = .yellow
        //        myTitleViewContainer.titleLabel = myTitleText
        //        myTitleViewContainer.backgroundColor = .blue
        //        flaneurPicker.navigationBar.topItem?.titleView = myTitleViewContainer

        flaneurPicker.config.removeButtonColor = .red
        
        flaneurPicker.config.backgroundColorForSection = [
            .pickerView: UIColor(red: 36/255, green: 41/255, blue: 50/255, alpha: 1),
            .imageSources: UIColor(red: 36/255, green: 41/255, blue: 50/255, alpha: 1),
            .selectedImages: UIColor(red: 36/255, green: 41/255, blue: 50/255, alpha: 1),
        ]

        flaneurPicker.config.paddingForImagesPickerView = UIEdgeInsets (top: 3, left: 3, bottom: 3, right: 3)
        flaneurPicker.delegate = self

        self.present(flaneurPicker, animated: true)
    }

}

extension ViewController: FlaneurImagePickerControllerDelegate {
    func flaneurImagePickerControllerDidCancel(_ picker: FlaneurImagePickerController) {
        print("didCancel")
        picker.dismiss(animated: true)
    }

    func flaneurImagePickerController(_ picker: FlaneurImagePickerController, didFinishPickingImages images: [FlaneurImageDescription], userInfo: Any?) {
        print("didFinishPickingImages")
        for image in images {
            print("* \(image)")
        }
        picker.dismiss(animated: true)
    }
}
