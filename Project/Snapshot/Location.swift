//
//  Location.swift
//  Snapshot
//
//  Created by Gustavo Araujo Santos on 10/18/24.
//

import Foundation
import CoreLocation
import OSLog

class LocationManager: NSObject {
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocation?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        checkAuthorization()
    }

    func getCurrentLocation() -> CLLocation? {
        return currentLocation
    }
    
    private func checkAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            logger.debug("Location access authorized.")
            locationManager.startUpdatingLocation()
        case .notDetermined:
            logger.debug("Location access not determined.")
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            logger.debug("Location access denied.")
        @unknown default:
            logger.debug("Location access unknown.")
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        logger.debug("Failed to get location: \(error.localizedDescription)")
    }
}

fileprivate let logger = Logger(subsystem: "com.gustavo.Snapshot", category: "Location")
