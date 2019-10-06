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
    override var annotation: MKAnnotation? {
        willSet {
            guard let photoMark = newValue as? PhotoMark else {
                return
            }
            canShowCallout = true
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            if let markImage = photoMark.markerImage {
                image = markImage
            } else {
                image = nil
            }
        }
    }
}
