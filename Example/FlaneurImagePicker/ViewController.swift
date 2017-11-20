//
//  ViewController.swift
//  FlaneurImagePickerController
//
//  Created by Flâneur on 11/07/2017.
//
//

import UIKit
import FlaneurImagePicker


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
        flaneurPicker.navigationBar.tintColor = .magenta
        flaneurPicker.navigationBar.barTintColor = .red
        flaneurPicker.navigationBar.isTranslucent = false
        flaneurPicker.navigationBar.topItem?.backBarButtonItem?.title = "MyCancel"
        flaneurPicker.navigationBar.topItem?.backBarButtonItem?.tintColor = .brown // <- this does nothing, the navigation bar tint color prevails
        flaneurPicker.navigationBar.topItem?.rightBarButtonItem?.title = "MySave"
        flaneurPicker.navigationBar.topItem?.rightBarButtonItem?.tintColor = .green
        flaneurPicker.navigationBar.topItem?.title = "MyTitle"
        flaneurPicker.navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "Futura-CondensedMedium", size: 16.0)!,
            NSForegroundColorAttributeName: UIColor.cyan
        ]

        flaneurPicker.config.removeButtonColor = .red
        flaneurPicker.config.backgroundColorForSection = { section in
            switch section {
            case .selectedImages:
                return .white
            case .imageSources:
                return UIColor(white: (236.0 / 255.0), alpha: 1.0)
            case .pickerView:
                return UIColor(white: (236.0 / 255.0), alpha: 1.0)
            }
        }
        flaneurPicker.config.sizeForImagesPickerView = { collectionSize in
            let arraySize = collectionSize.width / 3.0
            return CGSize(width: arraySize, height: arraySize)
        }
        flaneurPicker.config.paddingForImagesPickerView = UIEdgeInsets(top: 2.0,
                                                                       left: 2.0,
                                                                       bottom: 2.0,
                                                                       right: 2.0)

        flaneurPicker.config.imageForImageSource = { imageSource in
            switch imageSource {
            case .library:
                return UIImage(named: "Rectangle")
            default:
                return nil
            }
        }

        flaneurPicker.config.titleForImageSource = { imageSource in
            return nil
        }

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

    func flaneurImagePickerControllerDidFail(_ error: FlaneurImagePickerError) {
        print("ERROR -- \(error.localizedDescription)")
    }
}
