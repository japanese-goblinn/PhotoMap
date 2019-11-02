//
//  CLLocationCoordinate2DExtension.swift
//  PhotoMap
//
//  Created by Kirill Gorbachyonok on 11/2/19.
//  Copyright © 2019 Kiryl Harbachonak. All rights reserved.
//

import CoreLocation

extension CLLocationCoordinate2D {
    static func getCoordinate(from coordinate: String) -> CLLocationCoordinate2D? {
        let coordinates = coordinate.components(separatedBy: ",")
        guard
            let latitude = Double(coordinates[0]),
            let longitude = Double(coordinates[1])
        else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
