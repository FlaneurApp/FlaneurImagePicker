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

/// Specifies what action to perform when a new image is tapped.
public enum FlaneurImagePickerControllerAction {
    /// Adds the new image to the current selection (default).
    case add

    /// Replace the last item of the current selection with the new image.
    case replaceLast

    /// Do nothing: leave the current selection unchanged and ignore the new image.
    case doNothing
}

/// A set of methods that your delegate object must implement to interact with the image picker interface.
public protocol FlaneurImagePickerControllerDelegate: AnyObject {

    /// Tells the delegate that the user is done picking images.
    ///
    /// - Parameters:
    ///   - picker: The controller object managing the image picker interface.
    ///   - images: An array of picked images of type FlaneurImageDescription.
    ///   - userInfo: Arbitrary data that was passed to the controller.
    func flaneurImagePickerController(_ picker: FlaneurImagePickerController,
                                      didFinishPickingImages images: [FlaneurImageDescriptor],
                                      userInfo: Any?)

    /// Asks the delegate what to do with the new image the user just tapped.
    ///
    /// - Parameters:
    ///   - picker: The controller object managing the image picker interface.
    ///   - count: The current size of the image selection (ignoring the new image).
    ///   - newImage: The new image the user just tapped.
    /// - Returns: The action to perform regarding this new image.
    func flaneurImagePickerController(_ picker: FlaneurImagePickerController,
                                      withCurrentSelectionOfSize count: Int,
                                      actionForNewImageSelection newImage: FlaneurImageDescriptor) -> FlaneurImagePickerControllerAction

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

    /// The navigation bar of the view controller.
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

    /// The object that acts as the delegate of the picker view.
    open weak var delegate: FlaneurImagePickerControllerDelegate?

    /// Contains all the Image Picker's configurations, you can override those configs by setting their public properties
    /// from inside that object
    open var config: FlaneurImagePickerConfig = FlaneurImagePickerConfig()

    var userInfo: Any?

    var isChangingSource = false

    /// Array of already selected images.
    /// The page control changes if the number of item change.
    /// We also need to retrieve the adapter to refresh the UI
    var selectedImages: [FlaneurImageDescriptor] = [FlaneurImageDescriptor]() {
        didSet {
            // Refresh the collection view
            let newImageCount = selectedImages.count
            let adapter = adapterForSection(section: .selectedImages)
            adapter.performUpdates(animated: true) { [weak self] success in
                if success {
                    // Update the page control
                    let currentPage = newImageCount - 1
                    self?.pageControlManager.numberOfPages = newImageCount
                    self?.pageControlManager.goToPage(page: currentPage)
                }
            }
        }
    }

    /// Array of selectable images in the PickerView.
    /// We need to retrieve the adapter to refresh the UI
    var pickerViewImages: [FlaneurImageDescriptor] = [FlaneurImageDescriptor]() {
        didSet {
            self.refreshGalleryIfVisible()
        }
    }

    private var imageProviders: [FlaneurImageProvider]

    /// Currently used image provider
    var currentImageProvider: FlaneurImageProvider {
        didSet {
            fetchImagesForCurrentImageProvider()
        }
    }

    // MARK: - Initializers

    /// Init
    ///
    /// - Parameters:
    ///   - userInfo: Arbitrary data
    ///   - imageProviders: Array of image providers.
    ///   - selectedImages: An array of already selected images
    public init(userInfo: Any?,
                imageProviders: [FlaneurImageProvider],
                selectedImages: [FlaneurImageDescriptor]) {
        self.imageProviders = imageProviders
        self.selectedImages = selectedImages
        self.userInfo = userInfo

        // Since the camera requires a modal view, we don't want it as the 1st source being selected by the controller.
        guard let firstSource = imageProviders.first(where: { !($0 is FlaneurImageCameraProvider) })
            else {
                fatalError("At least one source that is not camera must be set.")
        }

        self.currentImageProvider = firstSource

        super.init(nibName: nil, bundle: nil)

        for (index, _) in self.imageProviders.enumerated() {
            self.imageProviders[index].delegate = self
        }
    }

    /// A required init
    required public init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }

    deinit {
        #if DEBUG
        debugPrint("Deallocated")
        #endif
    }

    // MARK: - Lifecyle callbacks

    /// viewDidLoad Lifecyle callback
    override public func viewDidLoad() {
        super.viewDidLoad()

        _ = UIFont.registerFont(bundle: BundleLoader.assetsBundle,
                                fontName: "Font Awesome 5 Free-Regular-400",
                                fontExtension: "otf")

        view.addSubview(navigationBar)
        layoutNavigationBar()

        createCollectionViews()
        createAdapters()
        fetchImagesForCurrentImageProvider()
    }

    /// Notifies the view controller that its view is about to be added to a view hierarchy.
    ///
    /// - Parameter animated: If `true`, the view is being added to the window using an animation.
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        selectedImagesCollectionView?.backgroundColor = config.backgroundColorForSection(.selectedImages)
        imageSourceSelectionCollectionView?.backgroundColor = config.backgroundColorForSection(.imageSources)
        galleryCollectionView?.backgroundColor = config.backgroundColorForSection(.pickerView)
    }

    /// Notifies the view controller that its view was added to a view hierarchy.
    ///
    /// - Parameter animated: If `true`, the view was added to the window using an animation.
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
                pageControl.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    collectionView.heightAnchor.constraint(equalToConstant: 245.0),
                    pageControl.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
                    pageControl.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor)                    ])
            case .imageSources:
                collectionView.heightAnchor.constraint(equalToConstant: 65.0).isActive = true
            case .pickerView: break // Do nothing, it will adjust to whatever the other are :)
            }
        }
    }


    // MARK: - Button Touched

    @objc func doneButtonTouched() {
        delegate?.flaneurImagePickerController(self,
                                               didFinishPickingImages: selectedImages,
                                               userInfo: userInfo)
    }

    @objc func cancelButtonTouched() {
        delegate?.flaneurImagePickerControllerDidCancel(self)
    }

    // MARK: - Managing first Image Source selection

    func fetchImagesForCurrentImageProvider() {
        guard galleryCollectionView != nil else { return }

        // MFL comment: not sure why this is needed but it was there before so
        // I kept it during some refactoring. The load more manager sounds like
        // not such a great idea so this should be improved at some point
        DispatchQueue.main.async {
            self.setLoadMoreManager()
        }

        if currentImageProvider.isAuthorized() {
            debugPrint("Fetching images from source: \(currentImageProvider.name)")
            currentImageProvider.fetchImagesFromSource()
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.isChangingSource = false
                self?.pickerViewImages = []
            }
        }
    }

    func selectDefaultImageSource(finished: Bool) {
        guard let shouldManageFirstSelection = imageSourceSelectionCollectionView?.indexPathsForSelectedItems?.isEmpty else { return }

        if shouldManageFirstSelection {
            if let sectionNumber = imageProviders.index(where: { $0.name == currentImageProvider.name }) {
                let myIndexPath = IndexPath(item: 0, section: sectionNumber)
                imageSourceSelectionCollectionView?.selectItem(at: myIndexPath,
                                                               animated: true,
                                                               scrollPosition: .left)

            }
        }
    }

    func refreshGalleryIfVisible() {
        DispatchQueue.main.async {
            if let galleryCollectionView = self.galleryCollectionView {
                if galleryCollectionView.frame.width > 0 {
                    let adapter = self.adapterForSection(section: .pickerView)
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

    internal func addImageToSelection(imageDescription: FlaneurImageDescriptor) {
        if let imageIndex = selectedImages.index(of: imageDescription) {
            pageControlManager.goToPage(page: imageIndex)
        } else {
            // It's a new image, what should we do with it?
            let action = delegate?.flaneurImagePickerController(self,
                                                                withCurrentSelectionOfSize: selectedImages.count,
                                                                actionForNewImageSelection: imageDescription) ?? .add
            switch action {
            case .add:
                selectedImages.append(imageDescription)
            case .replaceLast:
                // This is more complicated than removeLast + append but it's 1 operation
                // and it avoids nasty side-effects from selectedImages' didSet code.
                self.selectedImages.replaceSubrange((selectedImages.count - 1)..<selectedImages.count,
                                                    with: [imageDescription])
            case .doNothing:
                ()
            }
        }
    }

    internal func deleteImageFromSelection(withHashValue hashValue: Int) {
        self.selectedImages = self.selectedImages.filter { $0.hashValue != hashValue }
    }

    internal func switchToSource(_ newProvider: FlaneurImageProvider) {
        if newProvider.name != currentImageProvider.name || newProvider is FlaneurImageCameraProvider {
            showChangingSourceSpinner(forProvider: newProvider)
            currentImageProvider = newProvider
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
            self?.currentImageProvider.fetchNextPage()
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

    internal func showChangingSourceSpinner(forProvider provider: FlaneurImageProvider) {
        guard !(provider is FlaneurImageCameraProvider) else { return }

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
            return selectedImages.map { ImageDiffableWrapper(imageDescriptor: $0) }
        case .imageSources:
            return imageProviders.map { ImageProviderWrapper($0) }
        case .pickerView:
            var objects: [ListDiffable] = pickerViewImages.map { ImageDiffableWrapper(imageDescriptor: $0) }
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
            guard let wrapper = object as? ImageProviderWrapper else { fatalError("Invalid object") }

            let buttonTouchedClosure: ActionKitVoidClosure = { [weak self] in
                self?.switchToSource(wrapper.imageProvider)
            }

            return ImageSourcesSectionController(with: config,
                                                 numberOfSources: imageProviders.count,
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
        if section != .pickerView // The section is not the picker view
            || currentImageProvider.isAuthorized() // The image provider has already been authorized
        {
            return nil
        }

        let authorizeClosure: ActionKitVoidClosure = { [weak self] in
            self?.currentImageProvider.requestAuthorization { isPermissionGiven in
                if isPermissionGiven {
                    self?.currentImageProvider.fetchImagesFromSource()
                } else {
                    self?.presentAuthorizationSettingsAlert()
                }
            }
        }

        let sourceName: String = currentImageProvider.name

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
    public func presentingViewController(for: FlaneurImageProvider) -> UIViewController {
        return self
    }

    public func imageProvider(_ provider: FlaneurImageProvider, didLoadImages images: [FlaneurImageDescriptor]) {
        DispatchQueue.main.async {
            if self.currentImageProvider is FlaneurImageCameraProvider {
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

    public func imageProvider(_ provider: FlaneurImageProvider, didFailWithError error: Error) {
        let title = NSLocalizedString("Error", comment: "")
        self.pickerViewImages = []
        let alert = UIAlertController(title: title,
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                                      style: .cancel,
                                      handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
