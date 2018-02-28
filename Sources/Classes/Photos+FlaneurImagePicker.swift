//
//  Photos+FlaneurImagePicker.swift
//  ActionKit
//
//  Created by Mickaël Floc'hlay on 06/02/2018.
//

import Photos

extension PHFetchOptions {
    /// Creates a new set of options to fetch the *n* most recent objects of the fetched collection.
    ///
    /// - Parameter n: The maximum number of objects to include in the fetch result (or `0` for no limit)
    /// - Returns: a new set of options to fetch the *n* most recent objects of the fetched collection.
    static func latest(_ n: Int) -> PHFetchOptions {
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [ sortDescriptor ]
        fetchOptions.fetchLimit = n
        return fetchOptions
    }
}
