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

class PhotoMark: NSObject, MKAnnotation {
    let title: String?
//    let date: Date
//    let image: UIImage
    var category: Category
    let coordinate: CLLocationCoordinate2D
    
    var markerImage: UIImage? {
       UIImage(named: category.rawValue)
    }
        
    init(title: String, coordinate: CLLocationCoordinate2D, category: Category) {
        self.coordinate = coordinate
        self.title = title
        self.category = category
    }
}
