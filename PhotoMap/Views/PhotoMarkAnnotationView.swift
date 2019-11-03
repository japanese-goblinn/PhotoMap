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
            setNeedsDisplay()
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
        drawAnnotation(with: photoMark.category.color, strokeColor: .black)
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

}

