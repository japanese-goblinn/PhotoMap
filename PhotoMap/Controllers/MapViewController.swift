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
import Firebase

enum NavigationMode {
    case discover
    case follow
}

class MapViewController: UIViewController {

    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var navigationModeButton: UIButton!
    
    private var currentUser: User!
    
    private var categories = Category.allCases
    private var annotations = [PhotoMarkAnnotation]()
    private var filteredAnnotations = [PhotoMarkAnnotation]()
    
    private var lastLocationTap: CLLocationCoordinate2D?
    
    private let locationManager = CLLocationManager()
    private let scale: CLLocationDistance = 5000
    
    private var navigationMode: NavigationMode = .follow
    private lazy var discoverColorImage = UIImage(named: "location_discover")
    private lazy var followColorImage = UIImage(named: "location_follow")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let user = Auth.auth().currentUser else { return }
        currentUser = user
        definesPresentationContext = true
        mapView.delegate = self
        enableMapCenterOnUserPan()
        checkLocationServices()
        initData()
    }
    
    @IBAction private func categoriesButtonPressed(_ sender: UIButton) {
        let categoriesVC = CategoriesViewController()
        categoriesVC.delegate = self
        categoriesVC.categories = categories
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
    
    private func initData() {
        let ref = Database.database().reference(withPath: "annotations/\(currentUser.uid)")
        ref.observe(.childAdded) { snapshot in
            AnnoationDownloader.getAnnotation(from: snapshot) { [weak self] annotation in
                self?.annotations.append(annotation)
                self?.mapView.addAnnotation(annotation)
                self?.filterAnnotations()
            }
        }
        ref.keepSynced(true)
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
            lastLocationTap = mapView.convert(location, toCoordinateFrom: mapView)
            showCameraActionSheet()
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

}

//MARK: - Camera button related
extension MapViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   
    @IBAction private func cameraButtonPressed(_ sender: UIButton) {
        showCameraActionSheet()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard
            let image = info[.originalImage] as? UIImage,
            var coordinate = locationManager.location?.coordinate
        else {
            return
        }
        dismiss(animated: true)
        if let lastTap = lastLocationTap {
            coordinate = lastTap;
            lastLocationTap = nil;
        }
        let popupVC = PopupViewController()
        popupVC.delegate = self
        popupVC.newImage = image;
        popupVC.newAnnotationCoordiante = coordinate
        let nav = UINavigationController(rootViewController: popupVC)
        nav.isNavigationBarHidden = true
        nav.modalPresentationStyle = .overFullScreen
        present(nav, animated: true)
    }
    
    private func showCameraActionSheet() {
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
    
    private func showImagePickerController(for sourceType: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self;
        imagePickerController.sourceType = sourceType
        present(imagePickerController, animated: true)
    }
}

//MARK: - PhotoMark delegate
extension MapViewController: PhotoMarkAnnotationDelegate {
    func pass(annotation: PhotoMarkAnnotation?) {
        let popup = PopupViewController()
        popup.annotation = annotation
        popup.delegate = self
        let nav = UINavigationController(rootViewController: popup)
        nav.isNavigationBarHidden = true
        nav.modalPresentationStyle = .overFullScreen
        present(nav, animated: true)
    }
}

//MARK: - PopupViewController delegate
extension MapViewController: Updatable {
    func update(with annotation: PhotoMarkAnnotation, state: State) {
        mapView.removeAnnotations(mapView.annotations)
        switch state {
        case .new:
            annotations.append(annotation)
        case .updated:
            let index = annotations.firstIndex { oldAnnotation in
                oldAnnotation.id == annotation.id
            }
            annotations.remove(at: index!)
            annotations.append(annotation)
        }
        filterAnnotations()
        mapView.addAnnotations(filteredAnnotations)
    }
}

//MARK: - Categories delegate
extension MapViewController: Filterable {
    func filter(by choosedCategories: [Category]) {
        categories = choosedCategories
        filterAnnotations()
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(filteredAnnotations)
    }
    
    private func filterAnnotations() {
        filteredAnnotations = annotations.filter {
            categories.contains($0.category)
        }
    }
}
