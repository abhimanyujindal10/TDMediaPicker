//
//  TDMediaPreviewServiceManager.swift
//  ImagePicker
//
//  Created by Abhimanu Jindal on 28/06/17.
//  Copyright © 2017 Abhimanu Jindal. All rights reserved.
//

import Foundation
import Photos

protocol TDMediaPreviewServiceManagerDelegate: class {
    func mediaPreviewServiceManager(_ manager: TDMediaPreviewServiceManager, didUpdateCart cart: TDCart, updateType: TDCart.UpdateType, shouldDisplayAddMoreOption: Bool, shouldDisplayBottomBar: Bool)
}

class TDMediaPreviewServiceManager: TDCartServiceManagerDelegate{
    
    // MARK: - Variable(s)
    
    lazy private var mediaItems:[TDMedia] = []
    private var cartServiceManager = TDCartServiceManager.sharedInstance
    private var configServiceManager = TDConfigServiceManager.sharedInstance

    weak var delegate:TDMediaPreviewServiceManagerDelegate?
    
    public init() {
        cartServiceManager.add(delegate: self)
    }
    
    // MARK: - Public Method(s)
    
    func fetchMediaItems(){
        self.cartServiceManager.refresh()
    }
    
    func purgeData(){
        mediaItems.removeAll()
    }
    
    // MARK: ... Cart Method(s)
    
    func addMediaToCart(_ media: TDMedia){
        cartServiceManager.add(media)
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
    
    func updateCart(_ media: TDMedia, updateType: TDCart.UpdateType){
        if updateType == .delete{
            cartServiceManager.remove(media)
        }else if updateType == .edit{
            cartServiceManager.edit(media)
        }
    }

    func getNavigationThemeConfig()-> TDConfigViewStandard{
        return configServiceManager.navigationTheme
    }
    
    func getPreviewScreenConfig()-> TDConfigPreviewScreen{
        return configServiceManager.previewScreenConfig
    }
    // MARK: - CartService Manager Delegate Method(s)
    
    
    func cartServiceManager(_ manager: TDCartServiceManager, cartDidUpdate cart: TDCart, updateType: TDCart.UpdateType) {
        
        if updateType == .reload || updateType == .delete{
            mediaItems = cart.media
            if cartServiceManager.getConfig() == 1{
                self.delegate?.mediaPreviewServiceManager(self, didUpdateCart: cart, updateType: updateType, shouldDisplayAddMoreOption: true, shouldDisplayBottomBar: false)
                return
            }
            if cartServiceManager.getConfig() > cart.media.count{
                self.delegate?.mediaPreviewServiceManager(self, didUpdateCart: cart, updateType: updateType, shouldDisplayAddMoreOption: true, shouldDisplayBottomBar: true)
                return
            }
            self.delegate?.mediaPreviewServiceManager(self, didUpdateCart: cart, updateType: updateType, shouldDisplayAddMoreOption: false, shouldDisplayBottomBar: true)
            return
        }
        
        print("this updateType of TDCart is not supported \(updateType)")
    }
    
    func cartServiceManager(_ manager: TDCartServiceManager, cartmaximumUpdate maxCount:Int){
    }
}

