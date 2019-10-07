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
            guard let photoMark = newValue as? PhotoMarkAnnotation else {
                return
            }
            let someImage: UIImage = #imageLiteral(resourceName: "test_image")
            let imageView = UIImageView(image: someImage)
            imageView.frame = CGRect(x: 0, y: 0, width: 50, height: 40)
            leftCalloutAccessoryView = imageView
            canShowCallout = true
            let button = UIButton(type: .detailDisclosure)
            button.tintColor = .gray
            rightCalloutAccessoryView = button
            let detailLabel = UILabel()
            detailLabel.numberOfLines = 0
            detailLabel.font = detailLabel.font.withSize(12)
            detailLabel.textColor = .gray
            detailLabel.text = photoMark.date.asString
            calloutOffset = CGPoint(x: 0, y: 15)
            detailCalloutAccessoryView = detailLabel
            if let markImage = photoMark.markerImage {
                image = markImage
            } else {
                image = nil
            }
        }
    }
}
