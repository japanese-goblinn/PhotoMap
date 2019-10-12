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
        mapView.register(
            PhotoMarkAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier
        )
        enableMapCenterOnUserPan()
        checkLocationServices()
    }
    
    @IBAction func mapLongPressed(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            var location = sender.location(in: mapView)
            location.y -= 25
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            let mark = PhotoMarkAnnotation(
                title: "Default",
                date: Date(),
                coordinate: coordinate,
                category: .uncategorized
            )
            mapView.addAnnotation(mark)
        }
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

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        checkNavigationMode()
    }
    
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
        } else {
            print("Location services not enabled")
        }
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

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        centerView(on: annotation.coordinate)
    }
}
