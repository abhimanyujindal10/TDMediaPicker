//
//  TDAlbum.swift
//  ImagePicker
//
//  Created by Abhimanu Jindal on 26/06/17.
//  Copyright © 2017 Abhimanu Jindal. All rights reserved.
//

import Foundation
import Photos

open class TDAlbum: NSObject{
    
    open let collection: PHAssetCollection
    open private(set) var itemsCount: Int = 0
    open private(set) var albumMedia: TDMedia?
    open private(set) var id: String
    
    // MARK: - Initialization
    
    init(collection: PHAssetCollection) {
        self.collection = collection
        self.id = collection.localIdentifier
    }
    
    // MARK: - Public Method(s)
    
    func reload() {
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let itemsFetchResult = PHAsset.fetchAssets(in: collection, options: options)
        itemsCount = itemsFetchResult.count
        
        if itemsFetchResult.count > 0{
            albumMedia = TDMedia(albumID: self.id, asset: itemsFetchResult[0], caption: "")

        }
    }
}
