//
//  Filterable .swift
//  PhotoMap
//
//  Created by Kirill Gorbachyonok on 10/28/19.
//  Copyright © 2019 Kiryl Harbachonak. All rights reserved.
//

import Foundation

protocol Filterable: AnyObject {
    func filter(by choosedCategories: [Category])
}
