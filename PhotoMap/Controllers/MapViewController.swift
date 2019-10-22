//
//  ViewController.swift
//  PhotoMap
//
//  Created by Kiryl Harbachonak on 10/1/19.
//  Copyright © 2019 Kiryl Harbachonak. All rights reserved.
//

import UIKit
import os
import MapKit
import CoreLocation

enum NavigationMode {
    case discover
    case follow
}

class MapViewController: UIViewController {

    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var navigationModeButton: UIButton!
    
    private let locationManager = CLLocationManager()
    private let scale: CLLocationDistance = 5000
    private var navigationMode: NavigationMode = .follow
    private lazy var discoverColorImage = UIImage(named: "location_discover")
    private lazy var followColorImage = UIImage(named: "location_follow")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        enableMapCenterOnUserPan()
        checkLocationServices()
    }
    
    @IBAction private func categoriesButtonPressed(_ sender: UIButton) {
        let categoriesVC = CategoriesViewController()
        present(categoriesVC, animated: true)
    }
    
    @IBAction private func locationButtonPressed(_ sender: UIButton) {
        switch navigationMode {
        case .discover:
            setNavigation(to: .follow)
            checkNavigationMode()
        case .follow:
            setNavigation(to: .discover)
        }
    }
    
    private func checkNavigationMode() {
        switch navigationMode {
        case .follow:
            centerViewOnUserLocation()
        case .discover:
            break
        }
    }
    
    private func setNavigation(to mode: NavigationMode) {
        switch mode {
        case .discover:
            navigationMode = .discover
            navigationModeButton.setImage(discoverColorImage, for: .normal)
        case .follow:
            navigationMode = .follow
            navigationModeButton.setImage(followColorImage, for: .normal)
        }
    }
}

//MARK: - Location related stuff
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        checkNavigationMode()
    }
    
    private func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            centerView(on: location)
        }
    }
       
    private func centerView(on location: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion.init(
            center: location,
            latitudinalMeters: scale,
            longitudinalMeters: scale
        )
        mapView.setRegion(region, animated: true)
    }
    
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
        } else {
            print("Location services not enabled")
        }
    }
    
    private func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
        case .denied:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .authorizedAlways:
            break
        @unknown default:
            break
        }
    }
}

//MARK: - Gestures related
extension MapViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    private func enableMapCenterOnUserPan() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.didDragMap(_:)))
        panGesture.delegate = self
        mapView.addGestureRecognizer(panGesture)
    }
    
    @objc private func didDragMap(_ sender: UIGestureRecognizer) {
        if navigationMode == .follow {
            setNavigation(to: .discover)
            checkNavigationMode()
        }
    }
}

//MARK: - Map related
extension MapViewController: MKMapViewDelegate {
    
    @IBAction func mapLongPressed(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            var location = sender.location(in: mapView)
            location.y -= 25
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            addAnnotation(at: coordinate)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is PhotoMarkAnnotation else {
            return nil
        }
        guard let annotationView = mapView.dequeueReusableAnnotationView(
            withIdentifier: String(describing: PhotoMarkAnnotation.self)
        ) else {
            let newAnnotationView = PhotoMarkAnnotationView(
                annotation: annotation,
                reuseIdentifier: String(describing: PhotoMarkAnnotation.self)
            )
            newAnnotationView.controllerDelegate = self
            return newAnnotationView
        }
        annotationView.annotation = annotation
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard let userLocationView = mapView.view(for: userLocation) else {
            return
        }
        userLocationView.canShowCallout = false
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else {
            return
        }
        setNavigation(to: .discover)
        centerView(on: annotation.coordinate)
    }
    
    private func addAnnotation(at coordinate: CLLocationCoordinate2D, image: UIImage? = nil) {
        let mark = PhotoMarkAnnotation(
            title: "Default",
            date: Date(),
            image: image,
            coordinate: coordinate,
            category: .uncategorized
        )
        mapView.addAnnotation(mark)
    }
}

//MARK: - Camera button related
extension MapViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   
    @IBAction private func cameraButtonPressed(_ sender: UIButton) {
        let actionSheet = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        actionSheet.addAction(
            UIAlertAction(
                title: "Take a Picture",
                style: .default,
                handler: { [weak self] _ in
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        self?.showImagePickerController(for: .camera)
                    }
                }
            )
        )
        actionSheet.addAction(
            UIAlertAction(
                title: "Choose From Library",
                style: .default,
                handler: { [weak self] _ in
                    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                        self?.showImagePickerController(for: .photoLibrary)
                    }
                }
            )
        )
        actionSheet.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: { [weak self] _ in
                    self?.dismiss(animated: true)
                }
            )
        )
        present(actionSheet, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard
            let image = info[.originalImage] as? UIImage,
            let coordinate = locationManager.location?.coordinate
        else {
            return
        }
        addAnnotation(at: coordinate, image: image)
        dismiss(animated: true)
    }
    
    private func showImagePickerController(for sourceType: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self;
        imagePickerController.sourceType = sourceType
        self.present(imagePickerController, animated: true)
    }
}

//MARK: - PhotoMark delegate
extension MapViewController: PhotoMarkAnnotationDelegate {
    func pass(annotation: PhotoMarkAnnotation?) {
        let popup = PopupViewController()
        popup.modalPresentationStyle = .overCurrentContext
        popup.modalTransitionStyle = .crossDissolve
        popup.annotation = annotation
        present(popup, animated: true)
    }
}
