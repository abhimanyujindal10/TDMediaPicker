//
//  TDMediaPreviewThumbView.swift
//  ImagePicker
//
//  Created by Abhimanu Jindal on 28/06/17.
//  Copyright © 2017 Abhimanu Jindal. All rights reserved.
//

import UIKit

protocol TDMediaPreviewThumbViewDelegate: class {
    func previewThumbView(_ view: TDMediaPreviewThumbView, didTapMedia media: TDMedia, index: Int)
    func previewThumbViewDidTapAddOption(_ view: TDMediaPreviewThumbView)
}

private class CollectionItem{
    enum ItemType{
        case Media, AddOption
    }
    
    var type:ItemType
    var data:AnyObject
    
    init(type: ItemType, data: AnyObject) {
        self.type = type
        self.data = data
    }
}

class TDMediaPreviewThumbView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    // MARK: - Variable(s)
    
    weak var delegate: TDMediaPreviewThumbViewDelegate?
    
    private var collectionItems:[CollectionItem] = []
    private var selectedIndex: Int = 0
    
    private let rows: CGFloat = 1
    private let cellSpacing: CGFloat = 2
    
    @IBOutlet var collectionView:  UICollectionView!

    
    // MARK: - LifeCycle
    
    override func awakeFromNib() {
    }
    
    
    // MARK: - Public Method(s)
    
    func setupView(){
        TDMediaCell.registerCellWithType(.ImageThumb, collectionView: collectionView)
        TDMediaCell.registerCellWithType(.VideoThumb, collectionView: collectionView)
        TDAddOptionCell.registerCell(collectionView)
    }
    
    func purgeData(){
        collectionItems.removeAll()
    }
    
    func reload(cartItems: [TDMedia], updateType: TDCart.UpdateType, shouldDisplayAddMoreOption: Bool){
        
        collectionItems.removeAll()
        
        for (_, media) in cartItems.enumerated(){
            let item = CollectionItem.init(type: .Media, data: media as AnyObject)
            collectionItems.append(item)
        }
        
        if shouldDisplayAddMoreOption{
            let item = CollectionItem.init(type: .AddOption, data: "Add Option" as AnyObject)
            collectionItems.append(item)
        }
        
        collectionView.reloadData()
    }
    
    func reload(toIndex: Int){
        selectedIndex = toIndex
        collectionView.reloadData()
        
        let indexPath = IndexPath(row: selectedIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
    }
    
    // MARK: - Private Method(s)
    
    
    private func configureFrameViews(){
        for case let cell as TDMediaCell in collectionView.visibleCells {
            if let indexPath = collectionView.indexPath(for: cell) {
                configureFrameView(cell, indexPath: indexPath)
            }
        }
    }
    
    private func configureFrameView(_ cell: TDMediaCell, indexPath: IndexPath) {
        if selectedIndex ==  (indexPath as NSIndexPath).item{
            cell.processHighlighting(shouldDisplay: true)
        }
        else{
            cell.processHighlighting(shouldDisplay: false)
        }
    }
    
    private func setUpMediaCell(mediaItem: TDMedia, indexPath: IndexPath) -> TDMediaCell?{
        if mediaItem.asset.mediaType == .image{
            return TDMediaCell.mediaCellWithType(.ImageThumb, collectionView: collectionView, for: indexPath)
        }
        if mediaItem.asset.mediaType == .video{
            return TDMediaCell.mediaCellWithType(.VideoThumb, collectionView: collectionView, for: indexPath)
        }
        return nil
    }

    private func configureMediaCell(item: CollectionItem, indexPath: IndexPath)-> UICollectionViewCell{
        
        let cell: TDMediaCell?
        let media = item.data as! TDMedia
        cell = setUpMediaCell(mediaItem: media, indexPath: indexPath)
        
        if cell == nil{
            print("ERROR IN GENERATING CORRECT CELL")
            return UICollectionViewCell()
        }
        cell?.configure(media.asset)
        configureFrameView(cell!, indexPath: indexPath)
        
        return cell!
    }
    
    private func configureAddOptionCell(item: CollectionItem, indexPath: IndexPath)-> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: TDAddOptionCell.self), for: indexPath)
            as! TDAddOptionCell
        return cell
    }
    
    
    private func getMediaIndex(collectionIndex: Int) -> Int?{
        let mediaItems = collectionItems.filter { (item) -> Bool in
            return item.type == .Media
        }
        
        let mediaItem = collectionItems[collectionIndex]
        
        return mediaItems.index(where: { (element) -> Bool in
            return mediaItem === element
        })
        
    }
    
    // MARK: - Collection View Datasource Method(s)
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return collectionItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = collectionItems[(indexPath as NSIndexPath).item]

        if item.type == .Media{
            return configureMediaCell(item: item, indexPath: indexPath)
        }
        return configureAddOptionCell(item: item, indexPath: indexPath)        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = (collectionView.bounds.size.height - (rows - 1) * cellSpacing) / rows
        return CGSize(width: size, height: size)
    }
    
    // MARK: - Collection View Delegate Method(s)
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Just to avoid reload on tap of selected cell
        if selectedIndex == indexPath.item{
            return
        }
        
        let item = collectionItems[(indexPath as NSIndexPath).item]
        
        if item.type == .Media{
            let index = indexPath.item
            reload(toIndex: index)
            
            let mediaIndex = getMediaIndex(collectionIndex: index)
            let media = collectionItems[index].data as! TDMedia
            if mediaIndex != nil{
                self.delegate?.previewThumbView(self, didTapMedia: media, index: mediaIndex!)
            }
            return
        }
        if item.type == .AddOption{
            self.delegate?.previewThumbViewDidTapAddOption(self)
        }
    }

    
}

