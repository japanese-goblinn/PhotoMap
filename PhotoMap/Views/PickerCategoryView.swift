//
//  PickerCategoryView.swift
//  PhotoMap
//
//  Created by Kirill Gorbachyonok on 10/24/19.
//  Copyright © 2019 Kiryl Harbachonak. All rights reserved.
//

import UIKit

class PickerCategoryView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var annotationView: MapPinView!
    @IBOutlet weak var categorieLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initAll()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initAll()
    }
    
    private func initAll() {
        Bundle.main.loadNibNamed("PickerCategoryView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
