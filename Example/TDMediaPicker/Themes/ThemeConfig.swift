//
//  ThemeConfig.swift
//  TDMediaPicker
//
//  Created by Abhimanu Jindal on 04/09/17.
//  Copyright © 2017 abhimanyujindal10. All rights reserved.
//


import UIKit
import TDMediaPicker

class ThemeConfig {
    func getNavigationThemeConfig()->TDConfigViewStandard{
        fatalError("Concrete class must provide data")
    }
    
    func getImageSizeForAlbum()->CGSize{
        fatalError("Concrete class must provide data")
    }
    
    func getPermissionScreenConfig()->TDConfigPermissionScreen{
        fatalError("Concrete class must provide data")
    }
    
    
}

