//
//  Theme1.swift
//  TDMediaPicker
//
//  Created by Yapapp on 04/09/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import TDMediaPicker

class Theme7: ThemeConfig{
    
    override func getPermissionScreenConfig() -> TDConfigPermissionScreen {
        let permissionConfig = TDConfigPermissionScreen()
        permissionConfig.settingButton = TDConfigButtonImage.init(normalImage: UIImage.init(named: "scan_qr_button"), customSize: CGSize.init(width: 32, height: 32))
        permissionConfig.cancelButton = TDConfigButtonImage.init(normalImage: UIImage.init(named: "close"), customSize: CGSize.init(width: 16, height: 16))
        
        permissionConfig.caption = TDConfigLabel.init(backgroundColor: .clear, textConfig: TDConfigText.init(text: "Open the Settings to enable photos access for your app.", textColor: UIColor(rgb: 0xc0392b), textFont: UIFont.boldSystemFont(ofSize: 18)), textAlignment: .center, lineBreakMode: .byWordWrapping, minimumFontSize: 2.0)
        
        return permissionConfig
    }
    
    override func getNavigationThemeConfig() -> TDConfigViewStandard {
        return TDConfigViewStandard.init(backgroundColor: .clear)
    }
    
}


