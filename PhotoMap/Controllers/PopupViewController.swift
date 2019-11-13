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
    var category: Category?
    
    weak var delegate: Updatable?
    
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
            AnnotationUploader.upload(
                annotation: localAnnotation,
                image: image,
                as: .new
            )
            delegate?.update(with: localAnnotation, state: .new)
        }
        dismiss(animated: true)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func pickerPressed(_ sender: UITapGestureRecognizer) {
        let picker = PickerViewController()
        picker.modalPresentationStyle = .custom
        picker.modalTransitionStyle = .crossDissolve
        picker.choosedCategory = category ?? annotation!.category
        picker.delegate = self
        present(picker, animated: true)
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
        setupPicker()
        setupTextField()
        contentView.layer.cornerRadius = 6
        view.drawShadow()
        imageContainerView.drawShadow()
    }
    
    private func setOutletsData() {
        if let annotation = annotation {
            AnnoationDownloader.getImage(url: annotation.imageURL) { [weak self] image in
                self?.imageView.image = image
            }
            contentTextView.text = annotation.title
            dateLabel.text = annotation.date.toString(with: .full)
            updatePickerView(with: annotation.category)
        } else if
            let image = newImage
        {
            imageView.image = image
            dateLabel.text = Date().toString(with: .full)
            category = .uncategorized
            updatePickerView(with: .uncategorized)
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
    
    private func updatePickerView(with category: Category) {
        pickerView.annotationView.fillColor = category.color
        pickerView.categorieLabel.text = category.asString.uppercased()
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
        self.category = category
        updatePickerView(with: category)
    }
}
