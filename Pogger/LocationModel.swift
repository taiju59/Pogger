//
//  LocationModel.swift
//  Pogger
//
//  Created by Taiju Aoki on 2016/04/17.
//  Copyright © 2016年 Taiju Aoki. All rights reserved.
//

import CoreLocation

class LocationModel: NSObject, CLLocationManagerDelegate {

    private var lm: CLLocationManager! = nil
    static let sharedInstance = LocationModel()
    
    override private init() {
        super.init()
        lm = CLLocationManager()
        lm.delegate = self
        
        //位置情報取得の可否。バックグラウンドで実行中の場合にもアプリが位置情報を利用することを許可する
        lm.requestAlwaysAuthorization()
        //位置情報の精度
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let lq = LocationQuality(rawValue: userDefaults.integerForKey(Prefix.KEY_LOCATE_QUALITY)) {
            setAccuracy(lq)
        } else {
            lm.desiredAccuracy = kCLLocationAccuracyHundredMeters
        }
        lm.requestAlwaysAuthorization()
        lm.allowsBackgroundLocationUpdates = true
        // これを入れないと停止した場合に15分ぐらいで勝手に止まる
        lm.pausesLocationUpdatesAutomatically = false
        //位置情報取得間隔(m)
        //        lm.distanceFilter = 20
    }
    
    func setAccuracy(locateQuality: LocationQuality) {
        switch locateQuality {
        case .High:
            lm.desiredAccuracy = kCLLocationAccuracyBest
        case .Normal:
            lm.desiredAccuracy = kCLLocationAccuracyHundredMeters
        case .Low:
            lm.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        }
    }

    func startUpdatingLocation() {
        //        lm.requestLocation()
        lm.startUpdatingLocation()
    }
    
    func stopGetLocation() {
        lm.stopUpdatingLocation()
    }
    
    /** 位置情報取得成功時 */
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation){
        print("Success")
        
        // get address
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)-> Void in
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            if placemarks!.count > 0 {
                let pm = placemarks![0] as CLPlacemark
                Point.inputPoint(pm)
                //stop updating location to save battery life
                //                self.lm.stopUpdatingLocation()
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