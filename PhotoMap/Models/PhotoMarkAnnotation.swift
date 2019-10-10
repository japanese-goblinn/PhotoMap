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

enum Category {
    case friends
    case nature
    case uncategorized
    
    var asString: String {
        switch self {
        case .friends:
            return "friend"
        case .nature:
            return "nature"
        case .uncategorized:
            return "default"
        }
    }
    
    var color: UIColor {
        switch self {
        case .friends:
            return UIColor(hex: "#F4A523")
        case .nature:
            return UIColor(hex: "#578E18")
        case .uncategorized:
            return UIColor(hex: "#578E18")
        }
    }
}

class PhotoMarkAnnotation: NSObject, MKAnnotation {
    let title: String?
    let date: Date
//    let image: UIImage
    let category: Category
    let coordinate: CLLocationCoordinate2D
    
    var markerImage: UIImage? {
       UIImage(named: category.asString)
    }
        
    init(title: String, date: Date, coordinate: CLLocationCoordinate2D, category: Category) {
        self.title = title
        self.date = date
        self.coordinate = coordinate
        self.category = category
    }
}
