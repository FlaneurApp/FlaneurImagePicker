
//
//  PageControlManager.swift
//  FlaneurImagePickerController
//
//  Created by Frenchapp on 24/07/2017.
//  
//

import UIKit
import IGListKit

/*
 **  This class is used to move the page control as the pages change
*/

final class PageControlManager: NSObject {

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
    
    func pageControlValueChanged(sender: UIPageControl) {
        goToPage(page: sender.currentPage)
    }
    
    func goToPage(page: Int) {
        let scrollWidth = collectionView!.frame.width
        let scrollHeight = collectionView!.frame.height

        let scrollTo = CGRect(x: scrollWidth * CGFloat(page), y: CGFloat(0), width: scrollWidth, height: scrollHeight)

        collectionView?.scrollRectToVisible(scrollTo, animated: true)
    }

}

extension PageControlManager: UICollectionViewDelegate {
    func endScrolling(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.width
        let page = (scrollView.contentOffset.x + (0.5 * width)) / width
        currentIndex = Int(page)
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        endScrolling(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            endScrolling(scrollView)
        }
    }
}
