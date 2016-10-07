//
//  Point.swift
//  Pogger
//
//  Created by Taiju Aoki on 2016/07/06.
//  Copyright © 2016年 Taiju Aoki. All rights reserved.
//

import Foundation
import CoreLocation
import RealmSwift

class Point: Object {

    dynamic var id: String = UUID().uuidString
    dynamic var startDate: Date!
    dynamic var endDate: Date!
    dynamic var stayMin = 0
    dynamic var longitude = 0.0
    dynamic var latitude = 0.0
    dynamic var name: String?
    dynamic var thoroughfare: String?
    dynamic var subThoroughfare: String?
    dynamic var locality: String?
    dynamic var subLocality: String?
    dynamic var postalCode: String?
    dynamic var administrativeArea: String?
    dynamic var country: String?
    dynamic var favorite = false
    dynamic var changed = false

    override static func primaryKey() -> String? {
        return "id"
    }

    static private let pastLimitMin = 300

    static private let minUpdateMin = 5
    static private let distanceBoundary = 10.0

    static private let semaphore: DispatchSemaphore = DispatchSemaphore(value: 1)

    static func inputPoint(_ placemark: CLPlacemark) {
        semaphore.wait()
        let private_queue = DispatchQueue(label: "inputPoint", attributes: [])
        private_queue.async {
            let allPoints = try! Realm().objects(self).sorted(byProperty: "startDate", ascending: false)
            let allPointsCnt = allPoints.count

            if allPointsCnt > 0 {
                let lastPoint = allPoints[0]
                if isSamePlace(lastPoint, newPlace: placemark) {
                    updatePoint(placemark, allPoints: allPoints)
                } else {
                    addPoint(placemark, allPoints: allPoints)
                }
            } else {
                addPoint(placemark, allPoints: allPoints)
            }
            semaphore.signal()
        }
    }

    class func isSamePlace(_ oldPlace: Point, newPlace: CLPlacemark) -> Bool {
        let isMoved = calcDistance(oldPlace, to: newPlace) > distanceBoundary
        let isSameName = oldPlace.name == newPlace.name
        return !isMoved || isSameName
    }

    class func isSamePlace(_ oldPlace: Point, newPlace: FixedPoint) -> Bool {
        let isMoved = calcDistance(oldPlace, to: newPlace) > distanceBoundary
        let isSameName = oldPlace.name == newPlace.name
        return !isMoved || isSameName
    }

    class func calcDistance(_ oldPlace: Point, to newPlace: CLPlacemark) -> CLLocationDistance {

        let oldLocation = CLLocation(latitude: oldPlace.latitude, longitude: oldPlace.longitude)
        let newLocation = newPlace.location!
        let distance = newLocation.distance(from: oldLocation)

        return distance
    }

    class func calcDistance(_ oldPlace: Point, to newPlace: FixedPoint) -> CLLocationDistance {

        let oldLocation = CLLocation(latitude: oldPlace.latitude, longitude: oldPlace.longitude)
        let newLocation = CLLocation(latitude: newPlace.latitude, longitude: newPlace.longitude)
        let distance = newLocation.distance(from: oldLocation)

        return distance
    }

     static private func updatePoint(_ placemark: CLPlacemark, allPoints: Results<(Point)>) {
        let lastPoint = allPoints[0]

        let isSameMinute = lastPoint.endDate?.minute == Date().minute
        let isPast = lastPoint.endDate!.minute + pastLimitMin < Date().minute

        if !isSameMinute && !isPast {
            try! Realm().write {
                let now = Date()
                let stayMin = now.minute - lastPoint.startDate!.minute
                lastPoint.endDate = now
                lastPoint.stayMin = stayMin
            }
        }
    }

    static private func addPoint(_ placemark: CLPlacemark, allPoints: Results<(Point)>) {
        let realm = try! Realm()

        let point = Point()
        let now = Date()
        point.startDate = now
        point.endDate = now
        if let location = placemark.location {
            point.longitude = location.coordinate.longitude
            point.latitude = location.coordinate.latitude
        }
        point.name = placemark.name
        point.thoroughfare = placemark.thoroughfare
        point.subThoroughfare = placemark.subThoroughfare
        point.locality = placemark.locality
        point.subLocality = placemark.subLocality
        point.postalCode = placemark.postalCode
        point.administrativeArea = placemark.administrativeArea
        point.country = placemark.country

        do {
            try realm.write {
                realm.add(point)
            }
        } catch {
            print("RLM ERROR!!")
        }
    }

    class func switchFavorite(_ id: String, select: Bool) {
        let realm = try! Realm()
        do {
            try realm.write {
                let point = realm.objects(self).filter("id == \"\(id)\"")[0]
                point.favorite = select
            }
        } catch {
            print("RLM ERROR!!")
        }
    }
}
