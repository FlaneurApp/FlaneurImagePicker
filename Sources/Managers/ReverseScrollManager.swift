
//
//  CollectionViewReverseScrollManager.swift
//  FlaneurImagePickerController
//
//  Created by Flâneur on 31/07/2017.
//  
//


import UIKit
import IGListKit

/*
 **  The only purpose of this class is to scroll to the end of the collectionView when
 **  the datasource is the user's Library.
 **  This is the only way to do this action before any animation appears on the screen
*/

final class ReverseScrollManager: NSObject {
    
    weak var collectionView: UICollectionView?
 
    var isFirstTime = true
    
    var currentOffset: CGPoint?
}

extension ReverseScrollManager: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if isFirstTime {
            isFirstTime = false
            if collectionView.numberOfSections > 0 {
                var indexPath: IndexPath!
                if let previousOffset = self.currentOffset {
                    collectionView.setContentOffset(previousOffset, animated: true)
                } else {
                    indexPath = IndexPath(item: 0, section: collectionView.numberOfSections - 1)
                    collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
                }
            }
        } else {
            self.currentOffset = collectionView.contentOffset
        }
    }
}
