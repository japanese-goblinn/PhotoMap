//
//  StringExtension.swift
//  PhotoMap
//
//  Created by Kirill Gorbachyonok on 10/28/19.
//  Copyright © 2019 Kiryl Harbachonak. All rights reserved.
//

import Foundation

extension String {
    func toDate(with format: Format) -> Date? {
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
        return dateFormater.date(from: self)
    }
}
