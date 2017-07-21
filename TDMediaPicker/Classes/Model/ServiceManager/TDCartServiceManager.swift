//
//  TDCartServiceManager.swift
//  ImagePicker
//
//  Created by Abhimanu Jindal on 27/06/17.
//  Copyright © 2017 Abhimanu Jindal. All rights reserved.
//

import Foundation

protocol TDCartServiceManagerDelegate: class {
    func cartServiceManager(_ cart: TDCartServiceManager, cartDidUpdate totalMedia: [TDMedia], updateType: TDCart.UpdateType)
}


class TDCartServiceManager{
    
    // MARK: - Variable(s)

    static let sharedInstance = TDCartServiceManager()
    
    private var cart: TDCart = TDCart()
    private var maxSelection = 0
    
    var delegates: NSHashTable<AnyObject> = NSHashTable.weakObjects()
    
    // MARK: - Init
    private init(){}

    // MARK: - Public Method(s)
    
    func add(delegate: TDCartServiceManagerDelegate) {
        delegates.add(delegate)
    }
    
    func remove(delegate: TDCartServiceManagerDelegate) {
        delegates.remove(delegate)
    }
    
    func setupConfig(maxSelection: Int){
        self.maxSelection = maxSelection
    }
    
    func getConfig()-> Int{
        return self.maxSelection
    }
    
    func getSelectedMedia() -> [TDMedia]{
        return cart.media
    }
    
    // MARK: - Logic
    
    func contains(_ media: TDMedia) -> Bool{
        guard !cart.media.contains(where: { (element) -> Bool in
            return element.asset.localIdentifier == media.asset.localIdentifier
        })
        else {
            return false
        }
        return true
        
    }
    
    func add(_ media: TDMedia) {
        
        if !contains(media){
            return
        }
        if cart.media.count >= maxSelection{
            return
        }
        
        cart.media.append(media)
        
        for case let delegate as TDCartServiceManagerDelegate in delegates.allObjects {
            delegate.cartServiceManager(self, cartDidUpdate: cart.media, updateType: .add)
        }
    }
    
    func remove(_ media: TDMedia) {
        
        let index = cart.media.index(where: { (element) -> Bool in
            return element.asset.localIdentifier == media.asset.localIdentifier
        })
        
        if index != nil{
            cart.media.remove(at: index!)
        }
        else{
            return
        }
        
        for case let delegate as TDCartServiceManagerDelegate in delegates.allObjects {
            delegate.cartServiceManager(self, cartDidUpdate: cart.media, updateType: .delete)
        }
    }
    
    func purgeCache(){
        for (_,media) in cart.media.enumerated(){
            media.image = nil
        }
        for case let delegate as TDCartServiceManagerDelegate in delegates.allObjects {
            delegate.cartServiceManager(self, cartDidUpdate: cart.media, updateType: .purgeCache)
        }
    }
    
    func refresh(){
        for case let delegate as TDCartServiceManagerDelegate in delegates.allObjects {
            delegate.cartServiceManager(self, cartDidUpdate: cart.media, updateType: .reload)
        }
    }
    
    func reload(_ media: [TDMedia]) {
        cart.media = media
        
        for case let delegate as TDCartServiceManagerDelegate in delegates.allObjects {
            delegate.cartServiceManager(self, cartDidUpdate: cart.media, updateType: .reload)
        }
    }
    
    // MARK: - Reset
    
    func reset() {
        cart.media.removeAll()
    }
}
