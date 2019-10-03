//
//  Log.swift
//  PhotoMap
//
//  Created by Kiryl Harbachonak on 10/3/19.
//  Copyright © 2019 Kiryl Harbachonak. All rights reserved.
//

import os
import Foundation

private let subsystem = "com.kirylharbachonak.PhotoMap"

struct Log {
    static let mapAuthorizationStatus = OSLog(subsystem: subsystem, category: "Map authorization status")
}
