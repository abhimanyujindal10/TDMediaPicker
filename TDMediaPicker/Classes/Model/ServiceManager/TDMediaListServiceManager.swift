//
//  TDMediaListServiceManager.swift
//  ImagePicker
//
//  Created by Abhimanu Jindal on 26/06/17.
//  Copyright © 2017 Abhimanu Jindal. All rights reserved.
//

import Foundation
import Photos

protocol TDMediaListServiceManagerDelegate:class {
    func mediaListServiceManager(_ manager: TDMediaListServiceManager, didUpdateCart cart: TDCart, updateType: TDCart.UpdateType)
    func mediaListServiceManager(_ manager: TDMediaListServiceManager, cartmaximumUpdate maxCount:Int)

}

class TDMediaListServiceManager: TDCartServiceManagerDelegate {
    
    // MARK: - Variable(s)
    
    lazy private var mediaItems: [TDMedia] = []
    
    private var cartServiceManager = TDCartServiceManager.sharedInstance
    private var configServiceManager = TDConfigServiceManager.sharedInstance

    weak var delegate: TDMediaListServiceManagerDelegate?
    
    public init() {
        cartServiceManager.add(delegate: self)
    }
    
    // MARK: - Public Method(s)
    
    func fetchMediaItems(album: TDAlbum, completion: @escaping ([TDMedia]) -> Void){
        DispatchQueue.global().async {
            self.fetchMediaItemsFromLibrary(album: album)
            DispatchQueue.main.async {
                completion(self.mediaItems)
                self.cartServiceManager.refresh()
            }
        }
    }
    
    func fetchMedia(_ id:String, completion:(TDMedia?) -> Void){
        let matchedMedia = mediaItems.filter { (media) -> Bool in
            return media.id == id
        }
        if matchedMedia.count > 0{
            completion(matchedMedia[0])
            return
        }
        completion(nil)
    }
    
    func purgeData(){
        mediaItems.removeAll()
    }
    
    func getNavigationThemeConfig()-> TDConfigViewStandard{
        return configServiceManager.navigationTheme
    }
    
    func getMediaScreenConfig()-> TDConfigMediaScreen{
        return configServiceManager.mediaScreenConfig
    }
    func getConfig()-> Int{
        return self.cartServiceManager.getConfig()
    }
    // MARK: ... Cart Method(s)
    
    func updateCart(_ media: TDMedia, updateType: TDCart.UpdateType){
        if updateType == .add{
            cartServiceManager.add(media)
        }
        if updateType == .delete{
            cartServiceManager.remove(media)
        }
    }
    
    // MARK: - Private Method (s)
    
    private func fetchMediaItemsFromLibrary(album: TDAlbum){
        
        self.mediaItems.removeAll()
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let itemsFetchResult = PHAsset.fetchAssets(in: album.collection, options: options)
        itemsFetchResult.enumerateObjects({ (asset, count, stop) in
            self.mediaItems.append(TDMedia(albumID: album.id, asset: asset, caption: ""))
        })
    }
    
    // MARK: - CartService Manager Delegate Method(s)
    
    func cartServiceManager(_ manager: TDCartServiceManager, cartDidUpdate cart: TDCart, updateType: TDCart.UpdateType) {
        self.delegate?.mediaListServiceManager(self, didUpdateCart: cart, updateType: updateType)
    }
    func cartServiceManager(_ manager: TDCartServiceManager, cartmaximumUpdate maxCount:Int){
        self.delegate?.mediaListServiceManager(self, cartmaximumUpdate: maxCount)
    }
    
}

