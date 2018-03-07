//
//  TDMediaUtil+UIView.swift
//  ImagePicker
//
//  Created by Abhimanu Jindal on 25/06/17.
//  Copyright © 2017 Abhimanu Jindal. All rights reserved.
//

import UIKit

extension (TDMediaUtil){
    
    @discardableResult static func pin(on type1: NSLayoutAttribute,
                                       sourceView: UIView,
                                  view: UIView? = nil, on type2: NSLayoutAttribute? = nil,
                                  constant: CGFloat = 0,
                                  priority: Float? = nil) -> NSLayoutConstraint? {
        guard let view = view ?? sourceView.superview else {
            return nil
        }
        
        sourceView.translatesAutoresizingMaskIntoConstraints = false
        let type2 = type2 ?? type1
        let constraint = NSLayoutConstraint(item: sourceView, attribute: type1,
                                            relatedBy: .equal,
                                            toItem: view, attribute: type2,
                                            multiplier: 1, constant: constant)
        if let priority = priority {
            constraint.priority = UILayoutPriority(rawValue: priority)
        }
        
        constraint.isActive = true
        
        return constraint
    }
    
    static func pinEdges(sourceView: UIView, view: UIView? = nil) {
        pin(on: .top, sourceView: sourceView, view: view)
        pin(on: .bottom, sourceView: sourceView, view: view)
        pin(on: .left, sourceView: sourceView, view: view)
        pin(on: .right, sourceView: sourceView, view: view)
    }
    
    static func pin(sourceView: UIView, size: CGSize) {
        pin(sourceView: sourceView, width: size.width)
        pin(sourceView: sourceView, height: size.height)
    }
    
    static func pin(sourceView: UIView, width: CGFloat) {
        sourceView.translatesAutoresizingMaskIntoConstraints = false
        sourceView.addConstraint(NSLayoutConstraint(item: sourceView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width))
    }
    
    static func pin(sourceView: UIView, height: CGFloat) {
        sourceView.translatesAutoresizingMaskIntoConstraints = false
        sourceView.addConstraint(NSLayoutConstraint(item: sourceView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height))
    }
    
    static func pin(sourceView: UIView, greaterThanHeight height: CGFloat) {
        sourceView.translatesAutoresizingMaskIntoConstraints = false
        sourceView.addConstraint(NSLayoutConstraint(item: sourceView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height))
    }
    
    static func pinHorizontally(sourceView: UIView, view: UIView? = nil, padding: CGFloat) {
        pin(on: .left, sourceView: sourceView, view: view, constant: padding)
        pin(on: .right, sourceView: sourceView, view: view, constant: -padding)
    }
    
    static func pinUpward(sourceView: UIView, view: UIView? = nil) {
        pin(on: .top, sourceView: sourceView, view: view)
        pin(on: .left, sourceView: sourceView, view: view)
        pin(on: .right, sourceView: sourceView, view: view)
    }
    
    static func pinDownward(sourceView: UIView, view: UIView? = nil) {
        pin(on: .bottom, sourceView: sourceView, view: view)
        pin(on: .left, sourceView: sourceView, view: view)
        pin(on: .right, sourceView: sourceView, view: view)
    }
    
    static func pinCenter(sourceView: UIView, view: UIView? = nil) {
        pin(on: .centerX, sourceView: sourceView, view: view)
        pin(on: .centerY, sourceView: sourceView, view: view)
    }
}
