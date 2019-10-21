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
    
    weak var customCalloutView: PhotoMarkCalloutView?
    weak var controllerDelegate: PhotoMarkAnnotationDelegate?
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        frame.size.height = 57
        frame.size.width = 50
        backgroundColor = .clear
        canShowCallout = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        canShowCallout = false
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let parentHitView = super.hitTest(point, with: event) {
            return parentHitView
        } else {
            return customCalloutView?.hitTest(
                convert(point, to: customCalloutView!),
                with: event
            )
        }
    }
    
    override var annotation: MKAnnotation? {
        willSet {
            canShowCallout = false
            customCalloutView?.removeFromSuperview()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            customCalloutView?.removeFromSuperview()
            configureCalloutView()
            if animated {
                customCalloutView?.alpha = 0
                UIView.animate(withDuration: 0.3) {
                    self.customCalloutView?.alpha = 1
                }
            }
        } else {
            if let customCalloutView = customCalloutView {
                if animated {
                    UIView.animate(
                        withDuration: 0.3,
                        animations: {
                            customCalloutView.alpha = 0
                        }, completion: { _ in
                            customCalloutView.removeFromSuperview()
                        }
                    )
                } else {
                    customCalloutView.removeFromSuperview()
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        customCalloutView?.removeFromSuperview()
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
        
    private func configureCalloutView() {
        guard
            let newCalloutView = loadPhotoMarkCalloutView(),
            let newAnnotation = annotation as? PhotoMarkAnnotation
        else {
            return
        }
        newCalloutView.delegate = controllerDelegate
        newCalloutView.annotation = newAnnotation
        newCalloutView.frame.origin.x -= newCalloutView.frame.width / 2.0 - (frame.width / 2.0)
        newCalloutView.frame.origin.y -= newCalloutView.frame.height - 24
        addSubview(newCalloutView)
        customCalloutView = newCalloutView
    }
    
    private func loadPhotoMarkCalloutView() -> PhotoMarkCalloutView? {
        if let views = Bundle.main.loadNibNamed(
            "PhotoMarkCalloutView",
            owner: self,
            options: nil
        ) as? [PhotoMarkCalloutView] {
            let calloutView = views.first!
            return calloutView
        }
        return nil
    }
    
    private func drawBezier() -> UIBezierPath {
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
        return bezierPath
    }
    
    private func drawFillLayer(with color: UIColor) {
        let bezierPath = drawBezier()
        bezierPath.close()
        bezierPath.usesEvenOddFillRule = true
        color.setFill()
        bezierPath.fill()
    }
    
    private func drawBorderLayer(with color: UIColor, borderWidth: CGFloat) {
        let bezierPath = drawBezier()
        bezierPath.close()
        color.setStroke()
        bezierPath.lineWidth = borderWidth
        bezierPath.stroke()
    }
}

