//
//  LoadMoreManager.swift
//  FlaneurImagePickerController
//
//  Created by Frenchapp on 01/08/2017.
//  
//

import UIKit
import IGListKit

/*
 **  This class is meant to watch the Collection View and notify the adapter
 **  if the user has reached the end the list and the adapter should load more items.
 */

final class LoadMoreManager: NSObject {
    
    weak var collectionView: UICollectionView?
    weak var adapter: ListAdapter?
    
    var isLoading = false
    var hasNoMoreToLoad = false
    
    var loadMoreClosure: (() -> Void)?
}

extension LoadMoreManager: UICollectionViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let distance = scrollView.contentSize.height - (targetContentOffset.pointee.y + scrollView.bounds.height)
        if !hasNoMoreToLoad && !isLoading && distance < 200 {
            isLoading = true
            adapter?.performUpdates(animated: true, completion: nil)
            loadMoreClosure?()
        }

    }
}
