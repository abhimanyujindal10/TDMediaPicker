//
//  TDMediaPermissionView.swift
//  ImagePicker
//
//  Created by Abhimanu Jindal on 24/06/17.
//  Copyright © 2017 Abhimanu Jindal. All rights reserved.
//

import UIKit

protocol TDMediaPermissionViewDelegate:class {
    func permissionViewSettingsButtonTapped(_ view: TDMediaPermissionView)
    func permissionViewCloseButtonTapped(_ view: TDMediaPermissionView)
}

class TDMediaPermissionView: TDMediaPickerView{
    
    @IBOutlet var lblCaption: UILabel!
    @IBOutlet var btnSettings: UIButton!
    @IBOutlet var btnCancel: UIButton!
    
    weak var delegate:TDMediaPermissionViewDelegate?
    
    override func awakeFromNib() {
        
    }
    
    override func setupTheme() {
        
    }
    
    //MARK: - Public Method(s)
    
    func setupCustomView(view: TDConfigView){
        let tempViewConfig = view as! TDConfigViewCustom
        let tempView = tempViewConfig.view
        tempView.frame = CGRect.init(x: 0, y: 0, width: tempView.frame.width, height: tempView.frame.height)
        self.addSubview(tempView)
    }
    
    func setupStandardView(view: TDConfigView){
        let tempViewConfig = view as! TDConfigViewStandard
        self.backgroundColor = tempViewConfig.backgroundColor
    }
    
    func setupSettingsButton(buttonConfig: TDConfigButton){
        TDMediaUtil.setupButton(btnSettings, buttonConfig: buttonConfig)
    }
    
    func setupCancelButton(buttonConfig: TDConfigButton){
        TDMediaUtil.setupButton(btnCancel, buttonConfig: buttonConfig)
    }
    
    func setupCaptionLabel(_ config: TDConfigLabel){
        TDMediaUtil.setupLabel(lblCaption, config: config)
    }
    
    func setupDefaultScreen(){
        //setupTitleButtonConfig(config: TDConfigButtonText.init(normalColor: .white, normalTextConfig: TDConfigText.init(text: "Settings", textColor: .blue, textFont: UIFont.systemFont(ofSize: UIFont.systemFontSize))))
    }
    
    
    
    //MARK: - Action Method(s)
    
    @IBAction func settingsButtonTapped(){
        delegate?.permissionViewSettingsButtonTapped(self)
    }
    
    @IBAction func closeButtonTapped(){
        delegate?.permissionViewCloseButtonTapped(self)
    }
}
