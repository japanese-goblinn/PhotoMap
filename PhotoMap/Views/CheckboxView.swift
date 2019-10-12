//
//  CheckboxView.swift
//  PhotoMap
//
//  Created by Kirill Gorbachyonok on 10/10/19.
//  Copyright © 2019 Kiryl Harbachonak. All rights reserved.
//

import UIKit
import CoreGraphics

@IBDesignable
class CheckboxView: UIView {
    
    @IBInspectable var color: UIColor = .white {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var isChecked: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(
            ovalIn: CGRect(
                x: rect.minX + 1,
                y: rect.minY + 1,
                width: rect.width - 2,
                height: rect.height - 2
            )
        )
        if isChecked {
            color.setStroke()
            path.stroke()
        } else {
            color.setFill()
            path.fill()
        }
    }
}
