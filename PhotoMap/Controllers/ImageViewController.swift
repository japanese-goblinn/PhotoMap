//
//  ImageViewController.swift
//  PhotoMap
//
//  Created by Kirill Gorbachyonok on 10/23/19.
//  Copyright © 2019 Kiryl Harbachonak. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    
    var annoation: PhotoMarkAnnotation?

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var footerView: UIView!
    
    @IBAction func tapped(_ sender: UITapGestureRecognizer) {
        navigationController?.isNavigationBarHidden.toggle()
        footerView.isHidden.toggle()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationbar()
        setupOutletsData()
        addDoubleTapGesterRecognizer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = .systemBlue
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupNavigationbar()
    }
    
    private func setupNavigationbar() {
        navigationController?.navigationBar.barTintColor = UIColor(hex: "#252525")
        navigationController?.navigationBar.tintColor = .white
    }
    
    private func setupOutletsData() {
        if let annotation = annoation {
            contentLabel.text = annotation.title
            dateLabel.text = annotation.date.toString(with: .full)
            imageView.image = annotation.image
        }
    }
    
    private func addDoubleTapGesterRecognizer() {
        let tap = UITapGestureRecognizer(
            target: self, action: #selector(doubleTapped(_:))
        )
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
    }
    
    @objc private func doubleTapped(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: imageView)
        scrollView.zoom(
            to: CGRect(
                x: point.x,
                y: point.y,
                width: scrollView.minimumZoomScale,
                height: scrollView.minimumZoomScale
            ),
            animated: true
        )
    }
}

extension ImageViewController: UIScrollViewDelegate {
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateMinZoomScaleForSize(view.bounds.size)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraintsForSize(view.bounds.size)
    }

    private func updateMinZoomScaleForSize(_ size: CGSize) {
        let widthScale = size.width / imageView.bounds.width
        let heightScale = size.height / imageView.bounds.height
        let minScale = min(widthScale, heightScale)
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
    }
    
    private func updateConstraintsForSize(_ size: CGSize) {
        let yOffset = max(0, (size.height - imageView.frame.height) / 2)
        scrollView.contentOffset.y = yOffset
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset
        
        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset
        
        view.layoutIfNeeded()
    }
}
