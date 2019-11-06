//
//  PickerViewController.swift
//  PhotoMap
//
//  Created by Kirill Gorbachyonok on 10/24/19.
//  Copyright © 2019 Kiryl Harbachonak. All rights reserved.
//

import UIKit

class PickerViewController: UIViewController {

    weak var delegate: Categoriable?
    var choosedCategory: Category = .uncategorized
    
    @IBOutlet private weak var pickerView: UIPickerView!
    
    @IBAction private func pressToGoBack(_ sender: UITapGestureRecognizer) {
        delegate?.pass(category: choosedCategory)
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPickerDelegates()
        pickerView.selectRow(
            Category.allCases.firstIndex(of: choosedCategory) ?? 0,
            inComponent: 0,
            animated: true
        )
    }
    
    private func setPickerDelegates() {
        pickerView.delegate = self
        pickerView.dataSource = self
    }
}

extension PickerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Category.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Category.allCases[row].asString.uppercased()
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        choosedCategory = Category.allCases[row]
    }
}
