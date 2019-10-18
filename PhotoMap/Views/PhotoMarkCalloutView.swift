//
//  PhotoMarkCalloutView.swift
//  PhotoMap
//
//  Created by Kiryl Harbachonak on 10/9/19.
//  Copyright © 2019 Kiryl Harbachonak. All rights reserved.
//

import UIKit

class PhotoMarkCalloutView: UIView {
        
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        drawShadow(on: imageView)
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        let strokeColor = UIColor(
            red: 0.592,
            green: 0.592,
            blue: 0.592,
            alpha: 0.420
        )
        let fillColor2: UIColor = .white
        let bezier2Path = UIBezierPath()
        UIColor.black.setStroke()
        bezier2Path.lineWidth = 1
        bezier2Path.stroke()

        context.saveGState()
        context.beginTransparencyLayer(auxiliaryInfo: nil)
        let clipPath = drawBezier()
        clipPath.close()
        clipPath.usesEvenOddFillRule = true
        clipPath.addClip()

        let bezierPath = drawBezier()
        bezierPath.close()
        fillColor2.setFill()
        bezierPath.fill()

        context.endTransparencyLayer()
        context.restoreGState()

        context.saveGState()
        context.beginTransparencyLayer(auxiliaryInfo: nil)

        let clip2Path = drawBezier()
        clip2Path.close()
        clip2Path.usesEvenOddFillRule = true
        clip2Path.addClip()

        let bezier4Path = drawBezier()
        bezier4Path.close()
        strokeColor.setStroke()
        bezier4Path.lineWidth = 2
        bezier4Path.stroke()
        
        context.endTransparencyLayer()
        context.restoreGState()
    }
    
    private func drawBezier() -> UIBezierPath {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 27.2, y: 0.01))
        bezierPath.addLine(to: CGPoint(x: 192.8, y: 0.01))
        bezierPath.addCurve(to: CGPoint(x: 220, y: 25.27), controlPoint1: CGPoint(x: 207.82, y: 0.01), controlPoint2: CGPoint(x: 220, y: 11.32))
        bezierPath.addLine(to: CGPoint(x: 220, y: 55.29))
        bezierPath.addCurve(to: CGPoint(x: 192.8, y: 80.54), controlPoint1: CGPoint(x: 220, y: 69.23), controlPoint2: CGPoint(x: 207.82, y: 80.54))
        bezierPath.addCurve(to: CGPoint(x: 138.15, y: 80.54), controlPoint1: CGPoint(x: 161.99, y: 80.54), controlPoint2: CGPoint(x: 143.77, y: 80.54))
        bezierPath.addCurve(to: CGPoint(x: 110, y: 100.9), controlPoint1: CGPoint(x: 127.47, y: 80.54), controlPoint2: CGPoint(x: 121.42, y: 100.9))
        bezierPath.addCurve(to: CGPoint(x: 82, y: 80.54), controlPoint1: CGPoint(x: 99.19, y: 100.9), controlPoint2: CGPoint(x: 93.4, y: 80.54))
        bezierPath.addCurve(to: CGPoint(x: 27.2, y: 80.54), controlPoint1: CGPoint(x: 63.74, y: 80.54), controlPoint2: CGPoint(x: 45.47, y: 80.54))
        bezierPath.addCurve(to: CGPoint(x: 0, y: 55.29), controlPoint1: CGPoint(x: 12.18, y: 80.54), controlPoint2: CGPoint(x: 0, y: 69.23))
        bezierPath.addLine(to: CGPoint(x: 0, y: 25.27))
        bezierPath.addCurve(to: CGPoint(x: 27.2, y: 0.01), controlPoint1: CGPoint(x: 0, y: 11.32), controlPoint2: CGPoint(x: 12.18, y: 0.01))
        return bezierPath
    }
    
    private func drawShadow(on imageView: UIImageView) {
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOffset = CGSize(width: 0, height: 1)
        imageView.layer.shadowOpacity = 0.2
        imageView.layer.shadowRadius = 1.0
        imageView.clipsToBounds = false
    }
    
}
