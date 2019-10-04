//
//  Mark.swift
//  PhotoMap
//
//  Created by Kiryl Harbachonak on 10/4/19.
//  Copyright © 2019 Kiryl Harbachonak. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class Mark: NSObject, MKAnnotation {
    let title: String?
//    let date: Date
//    let image: UIImage
    let coordinate: CLLocationCoordinate2D
        
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
    }
}
