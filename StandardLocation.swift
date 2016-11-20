//
//  StandardLocation.swift
//  Pogger
//
//  Created by Taiju Aoki on 2017/01/04.
//  Copyright © 2017年 Taiju Aoki. All rights reserved.
//

import CoreLocation

protocol StandardLocationDelegate: class {
    func standardLocation(_ standardLocation: StandardLocation, manager: CLLocationManager, didUpdateLocation location: CLLocation)
    func standardLocation(_ standardLocation: StandardLocation, manager: CLLocationManager, didFailWithError error: Error)
}

class StandardLocation: NSObject, CLLocationManagerDelegate {

    private var manager = CLLocationManager()
    static let sharedInstance = StandardLocation()

    weak var delegate: StandardLocationDelegate?

    override private init() {
        super.init()
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false // これを入れないと停止した場合に15分ぐらいで勝手に止まる
        //位置情報精度
        let userDefaults = UserDefaults.standard
        if let lq = LocationQuality(rawValue: userDefaults.integer(forKey: Prefix.keyLocateQuality)) {
            setAccuracy(lq)
        } else {
            manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        }
    }

    func request() {
        manager.requestLocation()
    }

    func start() {
        manager.startUpdatingLocation()
    }

    func stop() {
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        delegate?.standardLocation(self, manager: manager, didUpdateLocation: manager.location!)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.standardLocation(self, manager: manager, didFailWithError: error)
    }

    func setAccuracy(_ locateQuality: LocationQuality) {
        switch locateQuality {
        case .high:
            manager.desiredAccuracy = kCLLocationAccuracyBest
        case .normal:
            manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        case .low:
            manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        }
    }
}
