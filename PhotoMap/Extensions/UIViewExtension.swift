//
//  UIViewExtension.swift
//  PhotoMap
//
//  Created by Kirill Gorbachyonok on 10/24/19.
//  Copyright © 2019 Kiryl Harbachonak. All rights reserved.
//

import UIKit

extension UIView {
    
    func drawShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 2, height: 2)
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 1.0
        clipsToBounds = false
    }
    
    func drawAnnotation(with fillColor: UIColor, strokeColor: UIColor) {
        drawAnnotationFillLayer(for: frame, with: fillColor)
        drawAnnotationBorderLayer(for: frame, with: strokeColor, borderWidth: 1.5)
    }
    
    private func drawAnnotationFillLayer(for rect: CGRect, with color: UIColor) {
        let bezierPath = drawAnnotationBezier(rect)
        bezierPath.close()
        bezierPath.usesEvenOddFillRule = true
        color.setFill()
        bezierPath.fill()
    }
    
    private func drawAnnotationBorderLayer(
        for rect: CGRect,
        with color: UIColor,
        borderWidth: CGFloat
    ) {
        let bezierPath = drawAnnotationBezier(rect)
        bezierPath.close()
        color.setStroke()
        bezierPath.lineWidth = borderWidth
        bezierPath.stroke()
    }
    
    private func drawAnnotationBezier(_ rect: CGRect) -> UIBezierPath {
        let bezierPath = UIBezierPath()
        bezierPath.move(
            to: CGPoint(x: rect.width * 0.4964, y: rect.height * 0.8947368421)
        )
        bezierPath.addCurve(
            to: CGPoint(x: rect.width * 0.6914, y: rect.height * 0.7524561404),
            controlPoint1: CGPoint(x: rect.width * 0.541, y: rect.height * 0.8664912281),
            controlPoint2: CGPoint(x: rect.width * 0.6068, y: rect.height * 0.8189473684)
        )
        bezierPath.addCurve(
            to: CGPoint(x: rect.width * 0.8952, y: rect.height * 0.4880701754),
            controlPoint1: CGPoint(x: rect.width * 0.728, y: rect.height * 0.7259649123),
            controlPoint2: CGPoint(x: rect.width * 0.877, y: rect.height * 0.5963157895)
        )
        bezierPath.addCurve(
            to: CGPoint(x: rect.width * 0.4964, y: rect.height * 0.1052631579),
            controlPoint1: CGPoint(x: rect.width * 0.9344, y: rect.height * 0.2519298246),
            controlPoint2: CGPoint(x: rect.width * 0.729, y: rect.height * 0.1052631579)
        )
        bezierPath.addCurve(
            to: CGPoint(x: rect.width * 0.1064, y: rect.height * 0.4880701754),
            controlPoint1: CGPoint(x: rect.width * 0.2638, y: rect.height * 0.1052631579),
            controlPoint2: CGPoint(x: rect.width * 0.0612, y: rect.height * 0.2814035088)
        )
        bezierPath.addCurve(
            to: CGPoint(x: rect.width * 0.2966, y: rect.height * 0.7524561404),
            controlPoint1: CGPoint(x: rect.width * 0.1344, y: rect.height * 0.6163157895),
            controlPoint2: CGPoint(x: rect.width * 0.2552, y: rect.height * 0.7221052632)
        )
        bezierPath.addCurve(
            to: CGPoint(x: rect.width * 0.4964, y: rect.height * 0.8947368421),
            controlPoint1: CGPoint(x: rect.width * 0.3884, y: rect.height * 0.8196491228),
            controlPoint2: CGPoint(x: rect.width * 0.455, y: rect.height * 0.8671929825)
        )
        return bezierPath
    }
}
