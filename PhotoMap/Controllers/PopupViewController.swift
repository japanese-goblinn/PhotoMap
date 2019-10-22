//
//  PopupViewController.swift
//  PhotoMap
//
//  Created by Kirill Gorbachyonok on 10/21/19.
//  Copyright © 2019 Kiryl Harbachonak. All rights reserved.
//

import UIKit

class PopupViewController: UIViewController {

    var annotation: PhotoMarkAnnotation?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setOutletsData()
    }
    
    private func setOutletsData() {
        if let annotation = annotation {
            imageView.image = annotation.image
            contentTextView.text = annotation.title
        }
    }
    
}
