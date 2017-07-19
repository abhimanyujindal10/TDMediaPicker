//
//  TDAlbumCell.swift
//  ImagePicker
//
//  Created by Abhimanu Jindal on 26/06/17.
//  Copyright © 2017 Abhimanu Jindal. All rights reserved.
//

import UIKit

class TDAlbumCell: UITableViewCell{
    
    // MARK: - Variables
    
    @IBOutlet var albumImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var countLabel: UILabel!
    
    // MARK: - Initialization
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
      //  fatalError("init(coder:) has not been implemented")

    }
    
    // MARK: - Config
    
    func configure(_ album: TDAlbum) {
        
        titleLabel.text = album.collection.localizedTitle
        countLabel.text = "\(album.itemsCount)"
        
        
        if let item = album.albumMedia {
            
            TDMediaUtil.fetchImage(item.asset, targetSize: albumImageView.frame.size, completionHandler: { (image, error) in
                if image != nil{
                    self.albumImageView.image = image
                }
            })
        }
    }
}
