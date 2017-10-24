//
//  ViewController.swift
//  FlaneurImagePickerController
//
//  Created by Frenchapp on 11/07/2017.
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
        flaneurPicker.config.cancelButtonTitle = "Cancel"
        flaneurPicker.config.doneButtonTitle = "Save"
        flaneurPicker.config.navBarTitle = "My custom title"
        
        flaneurPicker.config.navBarTitleColor = .black
        
//        flaneurPicker.config.navBarBackgroundColor = .cyan
        
        flaneurPicker.config.removeButtonColor = .red
        
        flaneurPicker.config.backgroundColorForSection = [
            .pickerView: UIColor(red: 36/255, green: 41/255, blue: 50/255, alpha: 1),
            .imageSources: UIColor(red: 36/255, green: 41/255, blue: 50/255, alpha: 1),
            .selectedImages: UIColor(red: 36/255, green: 41/255, blue: 50/255, alpha: 1),
        ]
        
//        flaneurPicker.config.authorizationViewCustomClass = TestView.self
        
        flaneurPicker.config.paddingForImagesPickerView = UIEdgeInsets (top: 3, left: 3, bottom: 3, right: 3)
//        flaneurPicker.config.sizeForImagesPickerView = CGSize(width: 100, height: 100)
        
//        flaneurPicker.config.imageSourcesBackgroundColor = [.instagram: .brown]
//        flaneurPicker.config.imageSourcesCellWidth = 200
        
        
//        flaneurPicker.config.sectionsOrderArray = [.imageSources, .pickerView, .selectedImages]
        
        flaneurPicker.delegate = self
        
        self.present(flaneurPicker, animated: true, completion: nil)
    }

}

extension ViewController: FlaneurImagePickerControllerDelegate {
    func didPickImages(images: [FlaneurImageDescription], userInfo: Any?) {
        print("didPickImages")
        for image in images {
            if image.imageSource == .urlBased {
                // Use the url property
                // Do something with => image.imageURL
                print(image.imageURL)
            } else { // .imageBased or .phassetBased
                // Use the image property
                // Do something with => image.image
                print(image.image)
            }
        }
    }
    
    func didCancelPickingImages() {
        print("didCancelPickingImages")
    }
}
