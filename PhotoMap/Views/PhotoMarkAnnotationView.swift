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
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        frame.size.height = 57
        frame.size.width = 50
        backgroundColor = .clear
        canShowCallout = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let photoMark = annotation as? PhotoMarkAnnotation else {
            return
        }
        let fillColor = photoMark.category.color
        let strokeColor: UIColor = .black
        drawFillLayer(with: fillColor)
        drawBorderLayer(with: strokeColor, borderWidth: 1.5)
    }
    
    private func drawFillLayer(with color: UIColor) {
       let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 24.82, y: 51))
        bezierPath.addCurve(
            to: CGPoint(x: 34.67, y: 42.89),
            controlPoint1: CGPoint(x: 27.05, y: 49.39),
            controlPoint2: CGPoint(x: 30.34, y: 46.68)
        )
        bezierPath.addCurve(
            to: CGPoint(x: 44.76, y: 27.82),
            controlPoint1: CGPoint(x: 36.4, y: 41.38),
            controlPoint2: CGPoint(x: 43.85, y: 33.99)
        )
        bezierPath.addCurve(
            to: CGPoint(x: 24.82, y: 6),
            controlPoint1: CGPoint(x: 46.72, y: 14.36),
            controlPoint2: CGPoint(x: 36.45, y: 6)
        )
        bezierPath.addCurve(
            to: CGPoint(x: 5.32, y: 27.82),
            controlPoint1: CGPoint(x: 13.19, y: 6),
            controlPoint2: CGPoint(x: 3.06, y: 16.04)
        )
        bezierPath.addCurve(
            to: CGPoint(x: 14.83, y: 42.89),
            controlPoint1: CGPoint(x: 6.72, y: 35.13),
            controlPoint2: CGPoint(x: 12.76, y: 41.16)
        )
        bezierPath.addCurve(
            to: CGPoint(x: 24.82, y: 51),
            controlPoint1: CGPoint(x: 19.42, y: 46.72),
            controlPoint2: CGPoint(x: 22.75, y: 49.43)
        )
        bezierPath.close()
        bezierPath.usesEvenOddFillRule = true
        color.setFill()
        bezierPath.fill()
    }
    
    private func drawBorderLayer(with color: UIColor, borderWidth: CGFloat) {
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 24.82, y: 51))
        bezier2Path.addCurve(
            to: CGPoint(x: 34.67, y: 42.89),
            controlPoint1: CGPoint(x: 27.05, y: 49.39),
            controlPoint2: CGPoint(x: 30.34, y: 46.68)
        )
        bezier2Path.addCurve(
            to: CGPoint(x: 44.76, y: 27.82),
            controlPoint1: CGPoint(x: 36.4, y: 41.38),
            controlPoint2: CGPoint(x: 43.85, y: 33.99)
        )
        bezier2Path.addCurve(
            to: CGPoint(x: 24.82, y: 6),
            controlPoint1: CGPoint(x: 46.72, y: 14.36),
            controlPoint2: CGPoint(x: 36.45, y: 6)
        )
        bezier2Path.addCurve(
            to: CGPoint(x: 5.32, y: 27.82),
            controlPoint1: CGPoint(x: 13.19, y: 6),
            controlPoint2: CGPoint(x: 3.06, y: 16.04)
        )
        bezier2Path.addCurve(
            to: CGPoint(x: 14.83, y: 42.89),
            controlPoint1: CGPoint(x: 6.72, y: 35.13),
            controlPoint2: CGPoint(x: 12.76, y: 41.16)
        )
        bezier2Path.addCurve(
            to: CGPoint(x: 24.82, y: 51),
            controlPoint1: CGPoint(x: 19.42, y: 46.72),
            controlPoint2: CGPoint(x: 22.75, y: 49.43)
        )
        bezier2Path.close()
        color.setStroke()
        bezier2Path.lineWidth = borderWidth
        bezier2Path.stroke()
    }
}

