//
//  ViewController.swift
//  PhotoMap
//
//  Created by Kiryl Harbachonak on 10/1/19.
//  Copyright © 2019 Kiryl Harbachonak. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    @IBOutlet private weak var mapView: MKMapView!
    
    private let locationManager = CLLocationManager()
    private let scale: CLLocationDistance = 5000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
    }
    
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            checkLocationAuthorization()
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

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        centerViewOnUserLocation()
    }
}
