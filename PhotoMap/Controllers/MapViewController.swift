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
            setFollowMode()
            checkNavigationMode()
        case .follow:
            setDiscoverMode()
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
    
    private func setFollowMode() {
        navigationMode = .follow
        navigationModeButton.setImage(followColorImage, for: .normal)
    }
    
    private func setDiscoverMode() {
        navigationMode = .discover
        navigationModeButton.setImage(discoverColorImage, for: .normal)
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
            os_log("Location services not enabled", log: Log.mapAuthorizationStatus, type: .error)
        }
    }
    
    private func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(
                center: location,
                latitudinalMeters: scale,
                longitudinalMeters: scale
            )
            mapView.setRegion(region, animated: true)
        }
    }
    
    private func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
            os_log("In Use", log: Log.mapAuthorizationStatus, type: .debug)
        case .denied:
            os_log("Denied", log: Log.mapAuthorizationStatus, type: .debug)
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            os_log("Not Determined", log: Log.mapAuthorizationStatus, type: .debug)
        case .restricted:
            os_log("Restricted", log: Log.mapAuthorizationStatus, type: .debug)
        case .authorizedAlways:
            os_log("Authorized Always", log: Log.mapAuthorizationStatus, type: .debug)
        @unknown default:
            os_log("Default", log: Log.mapAuthorizationStatus, type: .debug)
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
            setDiscoverMode()
            checkNavigationMode()
        }
    }
}
