//
//  LocationModel.swift
//  Pogger
//
//  Created by Taiju Aoki on 2016/04/17.
//  Copyright © 2016年 Taiju Aoki. All rights reserved.
//

import CoreLocation

class LocationModel: NSObject, CLLocationManagerDelegate {

    private var locationManager: CLLocationManager! = nil
    static let sharedInstance = LocationModel()

    override private init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager.delegate = self

        //位置情報取得の可否。バックグラウンドで実行中の場合にもアプリが位置情報を利用することを許可する
        locationManager.requestAlwaysAuthorization()
        //位置情報の精度
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let lq = LocationQuality(rawValue: userDefaults.integerForKey(Prefix.keyLocateQuality)) {
            setAccuracy(lq)
        } else {
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        }
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        // これを入れないと停止した場合に15分ぐらいで勝手に止まる
        locationManager.pausesLocationUpdatesAutomatically = false
        //位置情報取得間隔(m)
        //        locationManager.distanceFilter = 20
    }

    func setAccuracy(locateQuality: LocationQuality) {
        switch locateQuality {
        case .High:
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        case .Normal:
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        case .Low:
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        }
    }

    func startUpdatingLocation() {
        //        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
    }

    func stopGetLocation() {
        locationManager.stopUpdatingLocation()
    }

    /** 位置情報取得成功時 */
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
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
                //stop updating location to save battery life
                //                self.locationManager.stopUpdatingLocation()
            } else {
                print("Problem with the data received from geocoder")
            }
        })
    }

    /** 位置情報取得失敗時 */
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error")
    }
}
