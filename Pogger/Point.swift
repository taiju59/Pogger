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

// Model
class Point: Object {

    dynamic var id: String = UUID().uuidString
    dynamic var startDate = Date()
    dynamic var endDate: Date!
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

    override static func primaryKey() -> String? {
        return "id"
    }
}

// Calculate
extension Point {

    var stayMin: Int {
        let start = Int(startDate.timeIntervalSince1970)
        let end = Int(endDate.timeIntervalSince1970)
        return (end - start) / 60
    }

    static private let distanceBoundary = 50.0 // 同じ場所と判定する最大距離

    class func validateInsert(_ point: Point) -> Bool {
        let allPoints = try! Realm().objects(self).sorted(byProperty: "startDate", ascending: false)
        if allPoints.isEmpty {
            return true
        }
        return !isSamePlace(allPoints[0], and: point)
    }

    class func isSamePlace(_ oldPlace: Point, and newPlace: Point) -> Bool {
        let isMoved = calcDistance(from: oldPlace, to: newPlace) > distanceBoundary
        let isSameName = oldPlace.name == newPlace.name
        return !isMoved || isSameName
    }

    class func calcDistance(from oldPlace: Point, to newPlace: Point) -> Double {
        let oldLocation = CLLocation(latitude: oldPlace.latitude, longitude: oldPlace.longitude)
        let newLocation = CLLocation(latitude: newPlace.latitude, longitude: newPlace.longitude)
        let distance = newLocation.distance(from: oldLocation)

        return distance
    }
}

// Write
extension Point {

    static private let semaphore: DispatchSemaphore = DispatchSemaphore(value: 1)

    // モデル更新はこの関数を通して行う
    private static func packRlmAccess(function: @escaping () -> Swift.Void) {
        semaphore.wait()
        DispatchQueue(label: "rlmWrite").async {
            defer {
                semaphore.signal()
            }
            function()
        }
    }

    class func updatePoint(_ point: Point) {
        packRlmAccess {
            let realm = try! Realm()
            let allPoints = realm.objects(self).sorted(byProperty: "startDate", ascending: false)
            if !allPoints.isEmpty {
                let lastPoint = allPoints[0]
                try! realm.write {
                    lastPoint.latitude = point.latitude
                    lastPoint.longitude = point.longitude
                    lastPoint.endDate = point.endDate
                }
                NotificationCenter.default.post(name: NotificationNames.updatePoint, object: nil)
            }
        }
    }

    class func addPoint(_ point: Point) {
        packRlmAccess {
            let realm = try! Realm()
            try! realm.write {
                realm.add(point)
            }
            NotificationCenter.default.post(name: NotificationNames.addPoint, object: nil)
        }
    }

    class func switchFavorite(_ id: String, select: Bool) {
        packRlmAccess {
            let realm = try! Realm()
            let point = realm.objects(self).filter("id == \"\(id)\"")[0]
            try! realm.write {
                point.favorite = select
            }
            NotificationCenter.default.post(name: NotificationNames.switchFavorite, object: nil)
        }
    }
}
