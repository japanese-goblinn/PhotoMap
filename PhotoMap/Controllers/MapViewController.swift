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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
    }
    
    @IBAction private func locationButtonPressed(_ sender: UIButton) {
        switch navigationMode {
        case .discover:
            navigationMode = .follow
            //FIXME: change color
            navigationModeButton.tintColor = .blue
            centerViewOnUserLocation()
        case .follow:
            navigationMode = .discover
            //FIXME: change color
            navigationModeButton.tintColor = .black
        }
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
            os_log("In Use", log: Log.mapAuthorizationStatus, type: .debug)
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
        case .denied:
            os_log("Denied", log: Log.mapAuthorizationStatus, type: .debug)
        case .notDetermined:
            os_log("Not Determined", log: Log.mapAuthorizationStatus, type: .debug)
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            os_log("Restricted", log: Log.mapAuthorizationStatus, type: .debug)
        case .authorizedAlways:
            os_log("Authorized Always", log: Log.mapAuthorizationStatus, type: .debug)
        @unknown default:
            os_log("Default", log: Log.mapAuthorizationStatus, type: .debug)
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        switch navigationMode {
        case .follow:
            centerViewOnUserLocation()
        case .discover:
            break
        }
    }
}
