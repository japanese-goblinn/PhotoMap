//
//  PhotoMarkAnnotationView.swift
//  PhotoMap
//
//  Created by Kirill Gorbachyonok on 10/6/19.
//  Copyright © 2019 Kiryl Harbachonak. All rights reserved.
//

import Foundation
import CoreGraphics
import MapKit

class PhotoMarkAnnotationView: MKAnnotationView {
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let photoMark = annotation as? PhotoMarkAnnotation else {
            return
        }
        let ovalPath = UIBezierPath(ovalIn: CGRect(
            x: rect.minX,
            y: rect.minY,
            width: rect.width,
            height: rect.width
        ))
        photoMark.category.color.setFill()
        ovalPath.fill()
//        let bezierPath = UIBezierPath()
//        bezierPath.move(to: CGPoint(x: rect.width * 0.3, y: rect.minY))
//        bezierPath.addLine(to: CGPoint(x: rect.width * 0.5, y: rect.height))
//        bezierPath.addLine(to: CGPoint(x: rect.width * 0.7, y: rect.minY))
//        bezierPath.addLine(to: CGPoint(x: rect.width * 0.3, y: rect.minY))
//        bezierPath.close()
//        photoMark.category.color.setFill()
//        bezierPath.fill()
    }
    
    override var annotation: MKAnnotation? {
        willSet {
            frame.size.height = 50
            frame.size.width = 50
            backgroundColor = .clear
            canShowCallout = true
        }
    }
}

