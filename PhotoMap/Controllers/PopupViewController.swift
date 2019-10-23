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
    
    @IBOutlet weak var scrollView: UIScrollView!
//    @IBOutlet weak var imageView: UIImageView!
//    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activateKeyboardHandler()
        setOutletsData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setOutletsData() {
        if let annotation = annotation {
//            imageView.image = annotation.image
            contentTextView.text = annotation.title
        }
    }
}

extension PopupViewController: UITextViewDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           contentTextView.endEditing(true)
           return false
       }
    
    private func activateKeyboardHandler() {
        contentTextView.delegate = self
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo ?? [:]
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let contentInset = UIEdgeInsets(
            top: 0, left: 0, bottom: keyboardFrame.height, right: 0
        )
        setContentInsets(contentInset)
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        setContentInsets(.zero)
    }
    
    private func setContentInsets(_ insets: UIEdgeInsets) {
        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets
    }
}
