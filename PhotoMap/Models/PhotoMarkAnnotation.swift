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
import Firebase
import FirebaseStorage

enum Category: CaseIterable {
    
    case friends
    case nature
    case uncategorized
    
    var asString: String {
        switch self {
        case .friends:
            return "friends"
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
            return UIColor(hex: "#368EDF")
        }
    }
    
    static func toCategory(from category: String) -> Category? {
        switch category {
        case "friends":
            return .friends
        case "nature":
            return .nature
        case "default":
            return .uncategorized
        default:
            return nil
        }
    }
}

class PhotoMarkAnnotation: NSObject, MKAnnotation {
    let id: String
    var title: String?
    let date: Date
    var imageURL: String?
    var category: Category
    let coordinate: CLLocationCoordinate2D
    
    init(
        id: String = UUID().uuidString,
        title: String?,
        date: Date,
        imageURL: String?,
        coordinate: CLLocationCoordinate2D,
        category: Category
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.imageURL = imageURL
        self.coordinate = coordinate
        self.category = category
    }
    
    var asDictionary: [String: Any] {
        return [
            "id": id,
            "title": title as Any,
            "imageURL": imageURL as Any,
            "date": date.toString(with: .full),
            "coordinate": "\(coordinate.latitude),\(coordinate.longitude)",
            "category": category.asString
        ]
    }
}
