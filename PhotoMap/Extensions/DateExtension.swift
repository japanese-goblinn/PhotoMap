//
//  DateExtension.swift
//  PhotoMap
//
//  Created by Kiryl Harbachonak on 10/7/19.
//  Copyright © 2019 Kiryl Harbachonak. All rights reserved.
//

import Foundation

extension Date {
    var asString: String {
        let format = DateFormatter()
        format.dateFormat = "MM-dd-yyyy"
        return format.string(from: self)
    }
}
