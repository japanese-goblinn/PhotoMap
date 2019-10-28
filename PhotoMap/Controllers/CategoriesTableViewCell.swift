//
//  CategoriesTableViewCell.swift
//  PhotoMap
//
//  Created by Kirill Gorbachyonok on 10/10/19.
//  Copyright © 2019 Kiryl Harbachonak. All rights reserved.
//

import UIKit

class CategoriesTableViewCell: UITableViewCell {

    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryCheckbox: CheckboxView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
