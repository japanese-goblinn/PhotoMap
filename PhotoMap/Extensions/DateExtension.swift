//
//  DateExtension.swift
//  PhotoMap
//
//  Created by Kiryl Harbachonak on 10/7/19.
//  Copyright © 2019 Kiryl Harbachonak. All rights reserved.
//

import Foundation

enum Format {
    case standart
    case withTime
}

extension Date {
    func toString(format: Format) -> String {
        let dateFormater = DateFormatter()
        switch format {
        case .standart:
            dateFormater.dateFormat = "MM-dd-yyyy"
        case .withTime:
            dateFormater.amSymbol = "am"
            dateFormater.pmSymbol = "pm"
            dateFormater.dateFormat = "MMMM d'th', yyyy - h:mm a"
        }
        return dateFormater.string(from: self)
    }
}
