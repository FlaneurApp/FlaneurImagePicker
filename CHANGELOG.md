# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## Unreleased

* Flattened code source files hierarchy under `Sources/Classes`
* Renamed `FlaneurImageDescription` to `FlaneurImageDescriptor` that is now an enum
* Created `ImageDiffableWrapper` as a placeholder for all `FlaneurImageDescription`'s support code
* Added `PreUploadProcessor` and the `UIImage` extension

## [0.6.0] - 2018-02-20

* Updated `FlaneurImageProvider` to be more Swifty.
* Add `fetchLimit` configuration to `FlaneurImageLibraryProvider` (defauls to 0 ie fetch everything).
* Improved remove button [#3][3]: new icon button (via FontAwesome) as a replacement to the old text button (as a consequence, `removeButtonTitle` and `removeButtonColor` were removed from `FlaneurImagePickerConfig`).

## [0.5.1] - 2018-02-05

* Updated credits and contact info.

## [0.5.0] - 2018-01-18

* Removed the notion of maximum number of selected images, that's been replaced
  with a new delegation process that allows more flexibility for the caller:
  dynamically decide if she wants to keep adding to the selection, replacing
  the last item of the selection or doing nothing.
* Fixed a crash met randomly at development time that made UI calls from the
  background thread.
* Made some code simpler (including the selectedImages' `didSet` observer).
* When tapping an image that has already been selected, we scroll back to it to
  make it obvious why the selection doesn't change.
* Add logo for iPhone Example app.

## [0.4.0] - 2017-12-05

* Swift 4

## [0.3.0] - 2017-12-05

* Added `flaneurImagePickerControllerDidFail` to support error cases.
* Renamed `showAuthorisationSettinsPopup` to `presentAuthorizationSettingsAlert`.

## [0.2.0] - 2017-11-20

* Factorize and clean up code from: `FlaneurImageDescription`:
    * Using enum to associate `sourceType` and its associated value (ie URL, asset or image).
    * No caching done by `FlaneurImageDescription` for `PHAsset` as it's not its role and was not reliable (no track of the fetch options like quality, size, etc.).
    * Stop conforming to `NSObject`.
    * Added `requestImage` extension.
* Added `FlaneurImageView` as a view designed to be reusable (ie a subview of `UITableViewCell` or `UICollectionReusableView`).
* Fixed memory leak retaining `FlaneurImagePickerController` instances.
* Updated `FlaneurImagePickerControllerDelegate`:
    * Changed the functions' signature to be more similar to UIKit's `UIImagePickerControllerDelegate`.
    * Removed the dismiss code: the view controller shouldn't guess how it will be presented (a modal presentation is just one option).
* Fixed scrolling behavior of the selected images view.
* Made the `navigationBar` a `let` so that it can be customized at initialization time rather than loading time.
* Added the option to add image on the image source selection cells + introduce a selection style.
* Fixed: the `backgroundColorForSection` config parameter is now applied.

## [0.1.0] - 2017-10-24

Initial release of `FlaneurImagePicker`.

[0.6.0]: https://github.com/FlaneurApp/FlaneurImagePicker/compare/0.5.1...0.6.0
[0.5.1]: https://github.com/FlaneurApp/FlaneurImagePicker/compare/0.5.0...0.5.1
[0.5.0]: https://github.com/FlaneurApp/FlaneurImagePicker/compare/0.4.0...0.5.0
[0.4.0]: https://github.com/FlaneurApp/FlaneurImagePicker/compare/0.3.0...0.4.0
[0.3.0]: https://github.com/FlaneurApp/FlaneurImagePicker/compare/0.2.0...0.3.0
[0.2.0]: https://github.com/FlaneurApp/FlaneurImagePicker/compare/0.1.0...0.2.0
[0.1.0]: https://github.com/FlaneurApp/FlaneurImagePicker/tree/0.1.0

[3]: https://github.com/FlaneurApp/FlaneurImagePicker/issues/3
