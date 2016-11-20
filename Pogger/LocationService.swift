//
//  LocationService.swift
//  Pogger
//
//  Created by Taiju Aoki on 2016/04/17.
//  Copyright © 2016年 Taiju Aoki. All rights reserved.
//

import CoreLocation

class LocationService: NSObject, StandardLocationDelegate, VisitMonitoringDelegate {

    static let sharedInstance = LocationService()

    private(set) var newestLocation = CLLocation()

    override private init() {
        super.init()
        StandardLocation.sharedInstance.delegate = self
        VisitMonitoring.sharedInstance.delegate = self
    }

    func requestLocation() {
        StandardLocation.sharedInstance.request()
    }

    func startVisitMonitoring() {
        VisitMonitoring.sharedInstance.start()
    }

    func standardLocation(_ standardLocation: StandardLocation, manager: CLLocationManager, didUpdateLocation location: CLLocation) {
        newestLocation = location
        getAddress(for: location, completion: {
            placeMark in
            let now = Date()
            let point = placeMark.toPoint(startDate: now, endDate: now)
            if Point.validateInsert(point) {
                Point.addPoint(point)
            } else {
                Point.updatePoint(point)
            }
        })
    }

    func standardLocation(_ standardLocation: StandardLocation, manager: CLLocationManager, didFailWithError error: Error) {
        //TODO: エラー処理
    }

    func visitMonitoring(_ visitMonitoring: VisitMonitoring, manager: CLLocationManager, didVisit visit: CLVisit) {
        let location = CLLocation(latitude: visit.coordinate.latitude, longitude: visit.coordinate.longitude)
        newestLocation = location
        getAddress(for: location, completion: {
            placeMark in
            let point = placeMark.toPoint(startDate: visit.arrivalDate, endDate: visit.departureDate)
            if Point.validateInsert(point) {
                Point.addPoint(point)
            } else {
                Point.updatePoint(point)
            }
        })
    }

    private func getAddress(for location: CLLocation, completion: @escaping (CLPlacemark) -> Swift.Void) {
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if let error = error {
                print("住所取得失敗(1): " + error.localizedDescription)
                return
            }
            if !placemarks!.isEmpty {
                let placemark = placemarks![0] as CLPlacemark
                completion(placemark)
            } else {
                print("住所取得失敗(2): Problem with the data received from geocoder")
            }
        })
    }
}

fileprivate extension CLPlacemark {
    func toPoint(startDate: Date, endDate: Date) -> Point {
        let point = Point()
        point.startDate = startDate
        point.endDate = endDate
        point.longitude = location!.coordinate.longitude
        point.latitude = location!.coordinate.latitude
        point.name = self.name
        point.thoroughfare = self.thoroughfare
        point.subThoroughfare = self.subThoroughfare
        point.locality = self.locality
        point.subLocality = self.subLocality
        point.postalCode = self.postalCode
        point.administrativeArea = self.administrativeArea
        point.country = self.country
        return point
    }
}
