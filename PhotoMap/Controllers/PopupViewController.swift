//
//  PopupViewController.swift
//  PhotoMap
//
//  Created by Kirill Gorbachyonok on 10/21/19.
//  Copyright © 2019 Kiryl Harbachonak. All rights reserved.
//

import UIKit
import CoreLocation

class PopupViewController: UIViewController {

    var annotation: PhotoMarkAnnotation?
    var newAnnotationCoordiante: CLLocationCoordinate2D?
    var newImage: UIImage?
    var category: Category! {
        willSet {
            updatePickerView(with: newValue!)
        }
    }
    
    weak var delegate: Updatable?
    
    private let picker = UIPickerView()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pickerView: PickerCategoryView!
    @IBOutlet weak var dateLabel: UILabel!    
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        
        if let annotation = annotation {
            if let category = category {
                annotation.category = category
            }
            annotation.title = contentTextView.text
            AnnotationUploader.upload(
                annotation: annotation,
                image: newImage,
                as: .updated
            )
            delegate?.update(with: annotation, state: .updated)
        } else if
            let coordinate = newAnnotationCoordiante,
            let category = category,
            let image = newImage
        {
            let localAnnotation = PhotoMarkAnnotation(
                title: contentTextView.text,
                date: Date(),
                imageURL: nil,
                coordinate: coordinate,
                category: category
            )
            annotation = localAnnotation
            delegate?.update(with: localAnnotation, state: .new)
            AnnotationUploader.upload(
                annotation: localAnnotation,
                image: image,
                as: .new
            )
        }
        dismiss(animated: true)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func pickerPressed(_ sender: UITapGestureRecognizer) {
        pickerView.becomeFirstResponder()
    }
    
    @IBAction func imagePressed(_ sender: UITapGestureRecognizer) {
        let imageVC = ImageViewController()
        imageVC.annoation = annotation
        navigationController?.pushViewController(imageVC, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activateKeyboardHandler()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupViews() {
        setOutletsData()
        setupPickerView()
        setupPicker()
        setupTextField()
        contentView.layer.cornerRadius = 6
        view.drawShadow()
        imageContainerView.drawShadow()
    }
    
    private func setupPicker() {
        picker.delegate = self
        picker.dataSource = self
        picker.selectRow(Category.allCases.firstIndex(of: category)!, inComponent: 0, animated: true)
        pickerView.delegate = self
        pickerView.inputView = picker
        
    }
    
    private func setOutletsData() {
        if let annotation = annotation {
            imageView.image = .gifImageWithName("image_load")
            AnnoationDownloader.getImage(url: annotation.imageURL, or: annotation.id) {
                [weak self] image in
                
                if let image = image {
                    self?.imageView.image = image
                } else {
                    self?.imageView.image = #imageLiteral(resourceName: "image_error")
                }
            }
            contentTextView.text = annotation.title
            dateLabel.text = annotation.date.toString(with: .full)
            category = annotation.category
        } else if
            let image = newImage
        {
            imageView.image = image
            dateLabel.text = Date().toString(with: .full)
            category = .uncategorized
        }
    }
    
    private func setupTextField() {
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.borderColor = UIColor.gray.cgColor
    }
    
    private func setupPickerView() {
        pickerView.isUserInteractionEnabled = true
        pickerView.contentView.backgroundColor = .clear
        pickerView.layer.addBorder(edge: .top, color: .gray, thickness: 1)
        pickerView.layer.addBorder(edge: .bottom, color: .gray, thickness: 1)
    }
    
    private func updatePickerView(with category: Category) {
        pickerView.annotationView.fillColor = category.color
        pickerView.categoryLabel.text = category.asString.uppercased()
    }
}

extension PopupViewController: UITextViewDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return false
    }
    
    @IBAction private func hideKeyboard(_ sender: UITapGestureRecognizer) {
        pickerView.endEditing(true)
        contentTextView.endEditing(true)
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

extension PopupViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
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
        category = Category.allCases[row]
    }
    
}

extension PopupViewController: UITextFieldDelegate {}
