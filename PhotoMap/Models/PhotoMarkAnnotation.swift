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

enum Category: String {
    case friends = "category_friend"
    case nature = "category_nature"
    case `default` = "category_default"
}

class PhotoMarkAnnotation: NSObject, MKAnnotation {
    let title: String?
    let date: Date
//    let image: UIImage
    let category: Category
    let coordinate: CLLocationCoordinate2D
    
    var markerImage: UIImage? {
       UIImage(named: category.rawValue)
    }
        
    init(title: String, date: Date, coordinate: CLLocationCoordinate2D, category: Category) {
        self.title = title
        self.date = date
        self.coordinate = coordinate
        self.category = category
    }
}
