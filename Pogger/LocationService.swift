//
//  LocationService.swift
//  Pogger
//
//  Created by Taiju Aoki on 2016/04/17.
//  Copyright © 2016年 Taiju Aoki. All rights reserved.
//

import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate {

    private var locationManager: CLLocationManager! = nil
    static let sharedInstance = LocationService()

    override private init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager.delegate = self

        //位置情報取得の可否。バックグラウンドで実行中の場合にもアプリが位置情報を利用することを許可する
        locationManager.requestAlwaysAuthorization()
        //位置情報の精度
        let userDefaults = UserDefaults.standard
        if let lq = LocationQuality(rawValue: userDefaults.integer(forKey: Prefix.keyLocateQuality)) {
            setAccuracy(lq)
        } else {
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        }
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        // これを入れないと停止した場合に15分ぐらいで勝手に止まる
        locationManager.pausesLocationUpdatesAutomatically = false
    }

    func setAccuracy(_ locateQuality: LocationQuality) {
        switch locateQuality {
        case .high:
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        case .normal:
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        case .low:
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        }
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    func stopGetLocation() {
        locationManager.stopUpdatingLocation()
    }

    /** 位置情報取得成功時 */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Success")

        // get address
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            if !placemarks!.isEmpty {
                let pm = placemarks![0] as CLPlacemark
                Point.inputPoint(pm)
            } else {
                print("Problem with the data received from geocoder")
            }
        })
    }

    /** 位置情報取得失敗時 */
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error")
    }
}
