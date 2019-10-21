//
//  PhotoMarkAnnotationDelegate.swift
//  PhotoMap
//
//  Created by Kirill Gorbachyonok on 10/21/19.
//  Copyright © 2019 Kiryl Harbachonak. All rights reserved.
//

import Foundation

protocol PhotoMarkAnnotationDelegate: AnyObject {
    func pass(annotation: PhotoMarkAnnotation?)
}
