//
//  PhotoMarkCalloutView.swift
//  PhotoMap
//
//  Created by Kiryl Harbachonak on 10/9/19.
//  Copyright © 2019 Kiryl Harbachonak. All rights reserved.
//

import UIKit

class PhotoMarkCalloutView: UIView {
        
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .green
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let path = UIBezierPath(
            rect: CGRect(
                x: rect.minX,
                y: rect.minY,
                width: rect.width,
                height: rect.height - 15
            )
        )
        path.move(to: CGPoint(x: rect.midX - 30, y: rect.maxY - 15))
        path.addQuadCurve(
            to: CGPoint(x: rect.midX + 30, y: rect.maxY - 15),
            controlPoint: CGPoint(x: rect.midX, y: rect.maxY + 13)
        )
        UIColor.red.setFill()
        path.fill()
    }
}


