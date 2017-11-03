# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## Unreleased

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

[0.1.0]: https://github.com/FlaneurApp/FlaneurImagePicker/tree/0.1.0
