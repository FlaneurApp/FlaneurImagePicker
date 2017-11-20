//
//  FlaneurImagePickerController.swift
//  FlaneurImagePickerController
//
//  Created by Flâneur on 11/07/2017.
//  Copyright © 2017 Flâneur. All rights reserved.
//

import UIKit
import IGListKit
import ActionKit

/// A set of methods that your delegate object must implement to interact with the image picker interface.
public protocol FlaneurImagePickerControllerDelegate: AnyObject {

    /// Tells the delegate that the user picked images.
    ///
    /// - Parameters:
    ///   - picker: The controller object managing the image picker interface.
    ///   - images: An array of picked images of type FlaneurImageDescription.
    ///   - userInfo: Arbitrary data that was passed to the controller.
    func flaneurImagePickerController(_ picker: FlaneurImagePickerController,
                                      didFinishPickingImages images: [FlaneurImageDescription],
                                      userInfo: Any?)

    /// Tells the delegate that the user cancelled the pick operation.
    ///
    /// - Parameters:
    ///   - picker: The controller object managing the image picker interface.
    func flaneurImagePickerControllerDidCancel(_ picker: FlaneurImagePickerController)

    /// Tells the delegate that the image picker controller met an error.
    /// It shouldn't be called but it can be useful for error reporting on implementing clients.
    ///
    /// - Parameters:
    ///   - error: The error met by the picker.
    func flaneurImagePickerControllerDidFail(_ error: FlaneurImagePickerError)
}

/// An Image Picker that allows users to pick images from different sources (ex: user's library,
/// user's camera, instagram ...)
final public class FlaneurImagePickerController: UIViewController {

    // MARK: - Views
    public let navigationBar: UINavigationBar = {
        let navigationItem = UINavigationItem()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                           style: .done,
                                                           target: self,
                                                           action: #selector(cancelButtonTouched))

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(doneButtonTouched))

        let navigationBar = UINavigationBar()
        navigationBar.pushItem(navigationItem, animated: false)
        return navigationBar
    }()

    var collectionViews: [UICollectionView] = [UICollectionView]()
    private var selectedImagesCollectionView: UICollectionView?
    private var imageSourceSelectionCollectionView: UICollectionView?
    private var galleryCollectionView: UICollectionView?

    var pageControl = UIPageControl(frame: .zero)

    // MARK: - Initializers

    lazy var pageControlManager: PageControlManager = {
        let manager: PageControlManager = PageControlManager(with: self.pageControl, andConfig: self.config)
        manager.numberOfPages = self.selectedImages.count
        return manager
    }()

    var loadMoreManager: LoadMoreManager?

    let spinToken = "spinner"

    var adapters: [ListAdapter] = [ListAdapter]()

    /// Delegate property, should be set to whatever object you want to be notified in of the ImagePicker's events and
    /// which is conforming to *FlaneurImagePickerControllerDelegate*
    open weak var delegate: FlaneurImagePickerControllerDelegate?

    /// Contains all the Image Picker's configurations, you can override those configs by setting their public properties
    /// from inside that object
    open var config: FlaneurImagePickerConfig = FlaneurImagePickerConfig()

    var userInfo: Any?

    var isChangingSource = false

    /// Array of already selected images.
    /// The page control changes if the number of item change.
    /// We also need to retrieve the adapter to refresh the UI
    var selectedImages: [FlaneurImageDescription] = [FlaneurImageDescription]() {
        didSet {
            self.pageControlManager.numberOfPages = selectedImages.count

            let adapter = adapterForSection(section: .selectedImages)
            adapter.performUpdates(animated: true, completion: nil)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.pageControlManager.currentIndex = self!.selectedImages.count - 1
                self?.pageControlManager.goToPage(page: self!.pageControlManager.currentIndex)
            }

            if selectedImages.count ==  self.config.maxNumberOfSelectedImages {
                self.config.maxNumberOfSelectedImagesReachedClosure(self)
            }
        }
    }

    /// Array of selectable images in the PickerView.
    /// We need to retrieve the adapter to refresh the UI
    var pickerViewImages: [FlaneurImageDescription] = [FlaneurImageDescription]() {
        didSet {
            self.refreshGalleryIfVisible()
        }
    }

    /// Currently used image provider
    var imageProvider: FlaneurImageProvider!

    /// Currently selected image source
    var currentImageSource: FlaneurImageSource? {
        didSet {
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                guard let existingSelf = self else { return }
                guard let currentImageSource = existingSelf.currentImageSource else { return }
                existingSelf.loadMoreManager = nil

                switch currentImageSource {
                    // FIXME: the fact that the image picker controller has to switch defeats the
                // *plugin* intent of the providers.
                case .camera:
                    existingSelf.imageProvider = FlaneurImageCameraProvider(delegate: existingSelf, andParentVC: existingSelf)
                case .library:
                    existingSelf.imageProvider = FlaneurImageLibraryProvider(delegate: existingSelf, andConfig: existingSelf.config)
                case .instagram:
                    existingSelf.imageProvider = FlaneurImageInstagramProvider(delegate: existingSelf, andParentVC: existingSelf)
                    DispatchQueue.main.async {
                        self?.setLoadMoreManager()
                    }
                }

                if existingSelf.imageProvider.isAuthorized() {
                    existingSelf.imageProvider.fetchImagesFromSource()
                } else {
                    DispatchQueue.main.async { [weak self] in
                        self!.isChangingSource = false
                        self!.pickerViewImages = []
                    }
                }
            }
        }
    }



    // MARK: - Initializers

    /// Init
    ///
    /// - Parameters:
    ///   - maxNumberOfSelectedImages: Maximum number of pickable images
    ///   - userInfo: Arbitrary data
    ///   - sourcesDelegate: Array of image sources, aka: FlaneurImageSource
    ///   - selectedImages: An array of already selected images
    public init(maxNumberOfSelectedImages: Int,
                userInfo: Any?,
                sourcesDelegate: [FlaneurImageSource],
                selectedImages: [FlaneurImageDescription]) {

        if sourcesDelegate.count != 0 {
            self.config.imageSourcesArray = sourcesDelegate
        }

        self.selectedImages = selectedImages
        self.userInfo = userInfo
        self.config.maxNumberOfSelectedImages = maxNumberOfSelectedImages

        super.init(nibName: nil, bundle: nil)
    }

    /// A required init
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        ()
    }

    // MARK: - Lifecyle callbacks

    /// viewDidLoad Lifecyle callback
    override public func viewDidLoad() {
        super.viewDidLoad()

        searchFirstSource: for imageSource in config.imageSourcesArray {
            if imageSource != .camera {
                debugPrint("Setting image source as \(imageSource)")
                self.currentImageSource = imageSource
                break searchFirstSource
            }
        }

        view.addSubview(navigationBar)
        layoutNavigationBar()

        createCollectionViews()
        createAdapters()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        selectedImagesCollectionView?.backgroundColor = config.backgroundColorForSection(.selectedImages)
        imageSourceSelectionCollectionView?.backgroundColor = config.backgroundColorForSection(.imageSources)
        galleryCollectionView?.backgroundColor = config.backgroundColorForSection(.pickerView)
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Dirty hack
        refreshGalleryIfVisible()
    }

    /// viewDidLayoutSubviews Lifecyle callback
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        layoutCollectionViews()
    }

    // MARK: - Create Views

    private func createCollectionViews() {
        for section in config.sectionsOrderArray {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal

            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.alwaysBounceVertical = false
            collectionView.alwaysBounceHorizontal = false

            switch section {
            case .selectedImages:
                selectedImagesCollectionView = collectionView
                collectionView.isPagingEnabled = true
                pageControlManager.collectionView = collectionView

            case .pickerView:
                galleryCollectionView = collectionView
                collectionView.alwaysBounceVertical = true
                collectionView.setCollectionViewLayout(ListCollectionViewLayout(stickyHeaders: false, topContentInset: 0, stretchToEdge: true)
                    , animated: false)

            case .imageSources:
                imageSourceSelectionCollectionView = collectionView
            }

            collectionViews.append(collectionView)
            view.addSubview(collectionView)
        }
        view.addSubview(pageControl)
    }

    // MARK: - Create Adapters

    func createAdapters() {
        for _ in 0..<collectionViews.count {
            let listAdapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self)
            adapters.append(listAdapter)
        }

        for i in 0..<collectionViews.count {
            adapters[i].dataSource = self
            adapters[i].collectionView = collectionViews[i]
        }
    }

    // MARK: - Layout Functions

    func layoutNavigationBar() {
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: navigationBar,
                           attribute: .leading,
                           relatedBy: .equal,
                           toItem: view,
                           attribute: .leading,
                           multiplier: 1.0,
                           constant: 0.0).isActive = true
        NSLayoutConstraint(item: navigationBar,
                           attribute: .trailing,
                           relatedBy: .equal,
                           toItem: view,
                           attribute: .trailing,
                           multiplier: 1.0,
                           constant: 0.0).isActive = true
        NSLayoutConstraint(item: navigationBar,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: topLayoutGuide,
                           attribute: .bottom,
                           multiplier: 1.0,
                           constant: 0.0).isActive = true
    }

    func layoutCollectionViews() {
        for i in 0..<collectionViews.count {
            let collectionView = collectionViews[i]
            let currentSection = config.sectionsOrderArray[i]
            collectionView.translatesAutoresizingMaskIntoConstraints = false

            // Use all horizontal space
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true

            // Bind the previous view
            if i == 0 {
                collectionView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor).isActive = true
            } else {
                collectionView.topAnchor.constraint(equalTo: collectionViews[i - 1].bottomAnchor).isActive = true
            }

            // Bind last cell to the bottom
            if i == (collectionViews.count - 1) {
                NSLayoutConstraint(item: collectionView,
                                   attribute: .bottom,
                                   relatedBy: .equal,
                                   toItem: bottomLayoutGuide,
                                   attribute: .top,
                                   multiplier: 1.0,
                                   constant: 0.0).isActive = true
            }

            switch currentSection {
            case .selectedImages:
                collectionView.heightAnchor.constraint(equalToConstant: 245.0).isActive = true

                pageControl.translatesAutoresizingMaskIntoConstraints = false
                pageControl.widthAnchor.constraint(equalTo: collectionView.widthAnchor).isActive = true
                pageControl.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor).isActive = true
                pageControl.leftAnchor.constraint(equalTo: collectionView.leftAnchor).isActive = true
            case .imageSources:
                collectionView.heightAnchor.constraint(equalToConstant: 65.0).isActive = true
            case .pickerView: break // Do nothing, it will adjust to whatever the other are :)
            }
        }
    }


    // MARK: - Button Touched

    func doneButtonTouched() {
        delegate?.flaneurImagePickerController(self,
                                               didFinishPickingImages: selectedImages,
                                               userInfo: userInfo)
    }

    func cancelButtonTouched() {
        delegate?.flaneurImagePickerControllerDidCancel(self)
    }

    // MARK: - Managing first Image Source selection

    func selectDefaultImageSource(finished: Bool) {
        guard let shouldManageFirstSelection = imageSourceSelectionCollectionView?.indexPathsForSelectedItems?.isEmpty else { return }

        if shouldManageFirstSelection {
            if let imageSourceToSelect = self.currentImageSource {
                if let sectionNumber = self.config.imageSourcesArray.index(of: imageSourceToSelect) {
                    let myIndexPath = IndexPath(item: 0, section: sectionNumber)
                    imageSourceSelectionCollectionView?.selectItem(at: myIndexPath,
                                                                   animated: true,
                                                                   scrollPosition: .left)

                }
            }
        }
    }

    func refreshGalleryIfVisible() {
        if let galleryCollectionView = galleryCollectionView {
            if galleryCollectionView.frame.width > 0 {
                let adapter = adapterForSection(section: .pickerView)
                // For performance issues, we don't want to activate IGListKit's diffing
                // feature here (ie no `adapter.performUpdates(animated: true, completion: nil)`)
                adapter.reloadData(completion: self.selectDefaultImageSource)
            } else {
                debugPrint("Skipping reload as the galleryCollectionView seems to not be displayed right now (frame: \(galleryCollectionView.frame))")
            }
        } else {
            debugPrint("Skipping reload as the galleryCollectionView is nil right now.")
        }
    }
}


// MARK: Helpers

extension FlaneurImagePickerController {

    internal func adapterForSection(section: FlaneurImagePickerSection) -> ListAdapter {
        guard let sectionIndex = config.sectionsOrderArray.index(of: section),
            sectionIndex < adapters.count else {
                fatalError("Could not find adapter for section")
        }
        return adapters[sectionIndex]
    }

    internal func imageSourceForText(imageSourceRawValue: String) -> FlaneurImageSource {
        guard let candidate = FlaneurImageSource(rawValue: imageSourceRawValue) else {
            fatalError("No source for \(imageSourceRawValue)")
        }

        return candidate
    }

    internal func addImageToSelection(imageDescription: FlaneurImageDescription) {
        guard self.selectedImages.count < self.config.maxNumberOfSelectedImages else {
            return
        }
        if !self.selectedImages.contains(imageDescription) {
            self.selectedImages.append(imageDescription)
        }
    }

    internal func deleteImageFromSelection(withHashValue hashValue: Int) {
        self.selectedImages = self.selectedImages.filter { $0.hashValue != hashValue }
    }

    internal func switchToSource(withName imageSourceRawValue: String) {
        let source = imageSourceForText(imageSourceRawValue: imageSourceRawValue)
        if source != self.currentImageSource || source == .camera {
            self.showChangingSourceSpinner(forSource: source)
            self.currentImageSource = source
        }
    }

    internal func presentAuthorizationSettingsAlert() {
        let alert = UIAlertController(title: NSLocalizedString("Authorization", comment: ""),
                                      message: NSLocalizedString("You need to authorize the source in order to pick the photos", comment: ""),
                                      preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                                           style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingsUrl, completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(settingsUrl)
                }
            }
        }

        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""),
                                         style: .default) { (_) -> Void in
            alert.dismiss(animated: true, completion: nil)
        }

        alert.addAction(settingsAction)
        alert.addAction(cancelAction)

        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

    internal func setLoadMoreManager() {
        loadMoreManager = LoadMoreManager()
        let adapter = adapterForSection(section: .pickerView)

        adapter.collectionViewDelegate = loadMoreManager
        loadMoreManager?.adapter = adapter
        loadMoreManager?.collectionView = adapter.collectionView
        loadMoreManager?.loadMoreClosure = { [weak self] in
            self?.imageProvider?.fetchNextPage()
        }
    }

    internal func spinnerSectionController() -> ListSingleSectionController {
        let configureBlock = { (item: Any, cell: UICollectionViewCell) in
            guard let cell = cell as? SpinnerCell else { return }
            cell.activityIndicator.startAnimating()
        }

        let sizeBlock = { (item: Any, context: ListCollectionContext?) -> CGSize in
            guard let context = context else { return .zero }
            if self.isChangingSource {
                self.isChangingSource = false
                return CGSize(width: context.containerSize.width, height: context.containerSize.height)
            }
            return CGSize(width: context.containerSize.width, height: 100)
        }

        return ListSingleSectionController(cellClass: SpinnerCell.self,
                                           configureBlock: configureBlock,
                                           sizeBlock: sizeBlock)
    }

    internal func showChangingSourceSpinner(forSource source: FlaneurImageSource) {
        guard source != .camera else {
            return
        }
        DispatchQueue.main.async { [weak self] in
            self!.isChangingSource = true
            self!.pickerViewImages = []
        }
    }
}


// MARK: - ListAdapterDataSource

extension FlaneurImagePickerController: ListAdapterDataSource {

    /// A DataSource method used to feed the collection with data for a
    /// particular list adapter
    ///
    /// - Parameter listAdapter: The adapter asking for the data
    /// - Returns: An array of *ListDiffable* data
    public func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        guard let index = adapters.index(of: listAdapter) else {
            fatalError("Could not find section for adapter")
        }
        let section = config.sectionsOrderArray[index]

        switch section {
        case .selectedImages:
            return selectedImages
        case .imageSources:
            return self.config.imageSourcesArray.map { $0.rawValue } as [ListDiffable]
        case .pickerView:
            var objects = pickerViewImages as [ListDiffable]
            if let loadMoreManager = self.loadMoreManager, loadMoreManager.isLoading == true {
                objects.append(spinToken as ListDiffable)
            }
            if objects.count == 0 && isChangingSource == true {
                objects.append(spinToken as ListDiffable)
            }
            return objects
        }
    }

    /// A DataSource method used to associate a section controller
    /// to object of an adapter
    ///
    /// - Parameters:
    ///   - listAdapter: The adapter asking for the section controller
    ///   - object: The current object to be associated with a section controller
    /// - Returns: The section controller for the object
    public func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        guard let index = adapters.index(of: listAdapter) else {
            fatalError("Could not find section for adapter")
        }

        switch config.sectionsOrderArray[index] {
        case .selectedImages:
            let removeButtonClosure: ActionKitControlClosure = { [weak self] sender in
                self?.deleteImageFromSelection(withHashValue: (sender as! UIButton).tag)
            }

            let selectedImagesSectionController = SelectedImagesViewerSectionController(with: config, andRemoveButtonClosure: removeButtonClosure)
            selectedImagesSectionController.scrollDelegate = pageControlManager

            return selectedImagesSectionController

        case .imageSources:
            guard let imageSourceName = object as? String else { fatalError("Invalid object") }

            let buttonTouchedClosure: ActionKitVoidClosure = { [weak self] _ in
                self?.switchToSource(withName: imageSourceName)
            }

            return ImageSourcesSectionController(with: config,
                                                 andSelectHandler: buttonTouchedClosure)

        case .pickerView:
            if object is String {
                return spinnerSectionController()
            }
            let onImageSelectionClosure: ImageSelectionClosure = { [weak self] imageDescription in
                self?.addImageToSelection(imageDescription: imageDescription)
            }

            return PickerSectionController(with: config, andImageSelectedClosure: onImageSelectionClosure)
        }
    }

    ///  A DataSource method used to show an empty view in the collection
    ///  when data for an adapter are empty.
    ///
    /// - Parameter listAdapter: The adapter asking for the empty view.
    /// - Returns: A custom empty view of type UIView.
    public func emptyView(for listAdapter: ListAdapter) -> UIView? {
        guard let index = adapters.index(of: listAdapter) else {
            self.delegate?.flaneurImagePickerControllerDidFail(.emptyViewError("no section for adapter"))
            return nil
        }

        let section = config.sectionsOrderArray[index]
        if currentImageSource == nil // No current image source
            || section != .pickerView // The section is not the picker view
            || imageProvider.isAuthorized() // The image provider has already been authorized
        {
            return nil
        }

        let authorizeClosure: ActionKitVoidClosure = { [weak self] in
            self?.imageProvider.askForPermission { [weak self] isPermissionGiven in
                if isPermissionGiven {
                    self?.imageProvider.fetchImagesFromSource()
                } else {
                    self?.presentAuthorizationSettingsAlert()
                }
            }
        }
        let sourceName: String = currentImageSource!.rawValue

        if let customViewClass = config.authorizationViewCustomClass,
            let validClass = customViewClass.self as? FlaneurAuthorizationView.Type {
            return validClass.init(withSourceName: sourceName, authorizeClosure: authorizeClosure) as? UIView
        } else {
            return FlaneurAuthorizationDefaultView(withSourceName: sourceName,
                                                   authorizeClosure: authorizeClosure)
        }
    }
}

// MARK: - FlaneurImageProviderDelegate

extension FlaneurImagePickerController: FlaneurImageProviderDelegate {
    func didLoadImages(images: [FlaneurImageDescription]) {
        DispatchQueue.main.async {
            if self.currentImageSource! == .camera {
                self.addImageToSelection(imageDescription: images[0])
            } else {
                if let loadMoreManager = self.loadMoreManager, loadMoreManager.isLoading == true {
                    loadMoreManager.isLoading = false
                    loadMoreManager.hasNoMoreToLoad = images.count == 0 ? true : false
                    self.pickerViewImages += images
                } else {
                    self.pickerViewImages = images
                }
            }
        }
    }

    func didFailLoadingImages(with unauthorizedSourcePermission: FlaneurImageSource) {
        let title = NSLocalizedString("Error", comment: "")
        var message = ""

        self.pickerViewImages = []

        if unauthorizedSourcePermission == .camera {
            message = NSLocalizedString("Camera is not accessible on the device", comment: "")
        } else if unauthorizedSourcePermission == .instagram {
            message = NSLocalizedString("Check your internet connection", comment: "")
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)

        self.present(alert, animated: true, completion: nil)
    }
}
