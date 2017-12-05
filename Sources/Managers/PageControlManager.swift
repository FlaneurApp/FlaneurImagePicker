
//
//  PageControlManager.swift
//  FlaneurImagePickerController
//
//  Created by Flâneur on 24/07/2017.
//  
//

import UIKit
import IGListKit

/*
 **  This class is used to move the page control as the pages change
 */

final internal class PageControlManager: NSObject {

    weak var pageControl: UIPageControl?
    weak var collectionView: UICollectionView?
    
    var numberOfPages: Int = 0 {
        didSet {
            self.pageControl?.numberOfPages = numberOfPages
        }
    }
    
    var currentIndex: Int = 0 {
        didSet {
            self.pageControl?.currentPage = currentIndex
        }
    }
    
    init(with pageControl: UIPageControl, andConfig config: FlaneurImagePickerConfig) {
        super.init()

        pageControl.hidesForSinglePage = true
        pageControl.currentPage = 0
        
        pageControl.tintColor = config.pageControlCurrentIndexColor
        pageControl.pageIndicatorTintColor = config.pageControlTintColor
        
        pageControl.addTarget(self, action: #selector(pageControlValueChanged(sender:)), for: .valueChanged)
        
        self.pageControl = pageControl        
    }
    
    @objc func pageControlValueChanged(sender: UIPageControl) {
        goToPage(page: sender.currentPage)
    }
    
    func goToPage(page: Int) {
        let scrollWidth = collectionView!.frame.width
        let scrollHeight = collectionView!.frame.height

        let scrollTo = CGRect(x: scrollWidth * CGFloat(page), y: CGFloat(0), width: scrollWidth, height: scrollHeight)

        collectionView?.scrollRectToVisible(scrollTo, animated: true)
    }

}

extension PageControlManager: ListScrollDelegate {
    func listAdapter(_ listAdapter: ListAdapter, didScroll sectionController: ListSectionController) {
        if let scrollView = listAdapter.collectionView {
            let width = scrollView.bounds.width
            let page = (scrollView.contentOffset.x + (0.5 * width)) / width
            currentIndex = Int(page)
        }
    }

    func listAdapter(_ listAdapter: ListAdapter, willBeginDragging sectionController: ListSectionController) {
        ()
    }

    func listAdapter(_ listAdapter: ListAdapter, didEndDeceleratingSectionController sectionController: ListSectionController) {
        self.listAdapter(listAdapter, didScroll: sectionController)
    }

    func listAdapter(_ listAdapter: ListAdapter, didEndDragging sectionController: ListSectionController, willDecelerate decelerate: Bool) {
        if decelerate {
            self.listAdapter(listAdapter, didScroll: sectionController)
        }
    }
}
