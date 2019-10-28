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
    
    var categorie: Category = .uncategorized {
        willSet {
            color = newValue.color
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var isChecked: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var color: UIColor = .white
    
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
            color.setFill()
            path.fill()
        } else {
            color.setStroke()
            path.stroke()
        }
    }
}
