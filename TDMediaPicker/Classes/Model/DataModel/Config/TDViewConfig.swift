//
//  TDConfig.swift
//  Pods
//
//  Created by abhimanyujindal10 on 07/19/2017.
//  Copyright (c) 2017 abhimanyujindal10. All rights reserved.
//

import Foundation

protocol TDViewConfig{
}

open struct TDViewConfigStandard: TDViewConfig{
    
    open var backgroundColor: UIColor
    
    public init(backgroundColor: UIColor) {
        self.backgroundColor = backgroundColor
    }
}

open struct TDViewConfigCustom: TDViewConfig{
    
    open var view: UIView = UIView.init()
    
    public init(view: UIView) {
        super.init()
        self.view = view
    }
}
