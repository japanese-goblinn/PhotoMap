//
//  MapPinView.swift
//  PhotoMap
//
//  Created by Kirill Gorbachyonok on 10/24/19.
//  Copyright © 2019 Kiryl Harbachonak. All rights reserved.
//

import UIKit

@IBDesignable
class MapPinView: UIView {
    
    @IBInspectable
    var fillColor: UIColor = .clear {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var strokeColor: UIColor = .black {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        backgroundColor = .clear
        drawAnnotation(with: fillColor, strokeColor: strokeColor)
    }
}
