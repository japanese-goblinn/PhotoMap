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

    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var footerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationbar()
        setupOutletsData()
        addTapGesterRecognizers()
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delegate = self
        updateMinZoomScaleForSize(view.bounds.size)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupNavigationbar()
    }
    
    private func setupNavigationbar() {
        navigationController?.navigationBar.barTintColor = UIColor(hex: "#252525")
        navigationController?.navigationBar.tintColor = .white
        navigationController?.isNavigationBarHidden = false
    }
    
    private func setupOutletsData() {
        if let annotation = annoation {
            contentLabel.text = annotation.formattedTitle
            dateLabel.text = annotation.date.toString(with: .full)
            AnnoationDownloader.getImage(url: annotation.imageURL, or: annotation.id) { [weak self] image in
                self?.imageView.image = image
            }
        }
    }
    
    private func addTapGesterRecognizers() {
        let singleTap = UITapGestureRecognizer(
            target: self, action: #selector(tapped(_:))
        )
        singleTap.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(singleTap)
        
        let doubleTap = UITapGestureRecognizer(
            target: self, action: #selector(doubleTapped(_:))
        )
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
        
        singleTap.require(toFail: doubleTap)
    }
    
    @objc private func tapped(_ sender: UITapGestureRecognizer) {
        navigationController?.isNavigationBarHidden.toggle()
        footerView.isHidden.toggle()
    }
    
    @objc private func doubleTapped(_ sender: UITapGestureRecognizer) {
        if scrollView.zoomScale == scrollView.minimumZoomScale {
            let scale = min(scrollView.zoomScale * 2, scrollView.maximumZoomScale)
            if scale != scrollView.zoomScale {
                let point = sender.location(in: imageView)

                let scrollSize = scrollView.frame.size
                let size = CGSize(width: scrollSize.width / scale,
                                  height: scrollSize.height / scale)
                let origin = CGPoint(x: point.x - size.width / 2,
                                     y: point.y - size.height / 2)
                scrollView.zoom(to:CGRect(origin: origin, size: size), animated: true)
            }
        } else {
            scrollView.setZoomScale(-1, animated: true)
        }
    }
}

extension ImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateMinZoomScaleForSize(view.bounds.size)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraintsForSize(view.bounds.size)
    }

    private func updateConstraintsForSize(_ size: CGSize) {
        let yOffset = max(0, (size.height - imageView.frame.height) / 2)
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset
        
        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset
        
        view.layoutIfNeeded()
    }
    
    private func updateMinZoomScaleForSize(_ size: CGSize) {
        let widthScale = view.bounds.width / imageView.bounds.width
        let heightScale = view.bounds.height / imageView.bounds.height
        let minScale = min(widthScale, heightScale)
            
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
    }
}
