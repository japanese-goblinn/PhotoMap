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
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pickerView: PickerCategoryView!
    @IBOutlet weak var dateLabel: UILabel!    
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func pickerPressed(_ sender: UITapGestureRecognizer) {
        let picker = PickerViewController()
        picker.modalPresentationStyle = .custom
        picker.modalTransitionStyle = .crossDissolve
        picker.choosedCategory = annotation?.category ?? .uncategorized
        picker.delegate = self
        present(picker, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activateKeyboardHandler()
        setOutletsData()
        setupPicker()
        setupTextField()
        contentView.layer.cornerRadius = 4
        view.drawShadow()
        imageView.drawShadow()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setOutletsData() {
        if let annotation = annotation {
            imageView.image = annotation.image
            contentTextView.text = annotation.title
            dateLabel.text = annotation.date.toString(format: .withTime)
            updatePickerView(with: annotation)
        }
    }
    
    private func setupTextField() {
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.borderColor = UIColor.gray.cgColor
    }
    
    private func setupPicker() {
        pickerView.contentView.backgroundColor = .clear
        pickerView.layer.addBorder(edge: .top, color: .gray, thickness: 1)
        pickerView.layer.addBorder(edge: .bottom, color: .gray, thickness: 1)
    }
    
    private func updatePickerView(with annotation: PhotoMarkAnnotation) {
        pickerView.annotationView.fillColor = annotation.category.color
        pickerView.categorieLabel.text = annotation.category.asString.uppercased()
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

extension PopupViewController: Categoriable {
    func pass(category: Category) {
        guard let annoation = annotation else {
            return
        }
        annoation.category = category
        updatePickerView(with: annoation)
    }
}
