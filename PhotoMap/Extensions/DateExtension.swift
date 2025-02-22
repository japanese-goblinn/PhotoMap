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
    case monthAndYear
    case full
}

extension Date {
    func toString(with format: Format) -> String {
        let dateFormater = DateFormatter()
        switch format {
        case .standart:
            dateFormater.dateFormat = "MM-dd-yyyy"
        case .full:
            dateFormater.amSymbol = "am"
            dateFormater.pmSymbol = "pm"
            dateFormater.dateFormat = "MMMM d'th', yyyy - h:mm a"
        case .monthAndYear:
            dateFormater.dateFormat = "MMMM yyyy"
        }
        return dateFormater.string(from: self)
    }
}
