![FlaneurImagePicker logo](https://raw.githubusercontent.com/FlaneurApp/FlaneurImagePicker/master/Image.png)

[![CI Status](http://img.shields.io/travis/FlaneurApp/FlaneurImagePicker.svg?style=flat)](https://travis-ci.org/FlaneurApp/FlaneurImagePicker)
[![Version](https://img.shields.io/cocoapods/v/FlaneurImagePicker.svg?style=flat)](http://cocoapods.org/pods/FlaneurImagePicker)
[![License](https://img.shields.io/cocoapods/l/FlaneurImagePicker.svg?style=flat)](http://cocoapods.org/pods/FlaneurImagePicker)
[![Platform](https://img.shields.io/cocoapods/p/FlaneurImagePicker.svg?style=flat)](http://cocoapods.org/pods/FlaneurImagePicker)
[![Downloads](https://img.shields.io/cocoapods/at/FlaneurImagePicker.svg?style=flat)](http://cocoapods.org/pods/FlaneurImagePicker)

FlaneurImagePicker is a highly customizable iOS image picker that allows users to pick images from different sources (ex: device's library, device's camera, Instagram...), as used in the [Flâneur iOS app][flaneur-app-store].

## Features

* [x] Support for multiple image sources
* [x] New image sources can easily be added
* [x] Per-source authorization workflow
* [x] Customizable UI and behavior

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

* iOS 9
* Swift 4

## Installation

FlaneurImagePicker is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "FlaneurImagePicker"
```

## Getting Started

To launch the Flaneur Image Picker:

```swift
#import FlaneurImagePicker

let imagePicker = FlaneurImagePickerController(userInfo: nil,
                                               sourcesDelegate: [],
                                               selectedImages: [])
imagePicker.delegate = self
self.present(imagePicker, animated: true, completion: nil)
```

See the provided example to get a default implementation of the
`FlaneurImagePickerControllerDelegate` protocol.

## Property List Keys

Depending on the image sources you intend to integrate, you will need to add
values in your app's `.plist` file for the different sources:

```
<key>NSCameraUsageDescription</key>
<string>This application needs to access your camera</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>This application needs to access your photo library</string>

<key>InstagramClientID</key>
<string>YOUR_INSTAGRAM_CLIENT_ID</string>

<key>InstagramRedirectURI</key>
<string>YOUR_INSTAGRAM_REDIRECT_URI</string>
```

## Configuration

In order to configure the picker you can use the config object of the picker:

```swift
// Changes the cancel button's title
imagePicker.config.cancelButtonTitle = "Cancel"

// Changes the done button's color
imagePicker.config.doneButtonColor = .brown

// Changes the order of the sections
 imagePicker.config.sectionsOrderArray = [.imageSources, .pickerView, .selectedImages]

// Changes the title for the one or more imageSources
imagePicker.config.titleForImageSource = [.instagram: "Insta."]

// Changes height for one or more sections
imagePicker.config.heightForSection = [.selectedImages: Int(UIScreen.main.bounds.height / CGFloat(3)), .imageSources: 50]

// You can find all the possible configurations in the documentation
// as well as an example in the Example directory of the repo
...
```

## Instagram Support

To configure instagram, you need to go on the [instagram developer website](https://www.instagram.com/developer/)

- Create an account
- Go to the tab "Manage Clients"
- Register a New Client
- Fill the information
- Go back to the tab "Manage Client"
- Click on the button "Manage"
- Go to the tab "Security"
- Uncheck "Disable implicit OAuth"
- Enter a valid redirect URIs (the redirect URI that you choose doesn't really matter as long as it's an https address, you could use https://google.com for example)
- Copy the redirectURI in your .plist file (as explained [here](#plist_section))
- Copy the ClientID in your .plist file as explained [here](#plist_section))

When you create an account, you are in sandbox mode which means that you can only request the most 20 recents media of the user.

!!! Remember that media means PHOTOS AND VIDEOS, so if you only see 10 photos appearing in the picker, it means either that you only have 10 photos or that the rest of your most recent medias are videos !!!

In oder to test the picker when you're in sandbox mode, you need to add the users as sandbox users, to do so:

- Go to the tab "Sandbox"
- Enter the username of the user
- The user has to go to [instagram developer website](https://www.instagram.com/developer/)
- Create a developer account
- Go to Sandbox Invites
- And accept your invitation
- Then and ONLY THEN he can use the Picker

If you want to leave the Sandbox mode, you need to submit your app to instagram, read the documentation to do so: [instagram developer website](https://www.instagram.com/developer/)

## Documentation

You can find the documentation in the *docs* folder of the repository.
The `master` version of the documentation is also available [online](https://flaneurapp.github.io/FlaneurImagePicker/).

## Author

FlaneurApp, dev@flaneurapp.com

## Credits

[Photo by Joanna Kosinska](https://unsplash.com/photos/spAkZnUleVw)

## License

FlaneurImagePicker is available under the MIT license. See the LICENSE file for more info.

[flaneur-app-store]: https://itunes.apple.com/app/apple-store/id1076641994?pt=118094338&ct=FlaneurImagePickerGithub&mt=8
