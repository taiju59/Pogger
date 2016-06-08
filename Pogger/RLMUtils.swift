//
//  RLMUtils.swift
//  Pogger
//
//  Created by Taiju Aoki on 2016/06/08.
//  Copyright © 2016年 Taiju Aoki. All rights reserved.
//

import RealmSwift
import CoreLocation

class RLMUtils {
    
    static private let pastLimitMin = 300
    
    static private let minUpdateMin = 5
    static private let distanceBoundary = 10.0
    
    //セマフォを用意する
    static private let semaphore: dispatch_semaphore_t = dispatch_semaphore_create(1)
    
    static func inputPoint(placemark: CLPlacemark) {
        print("inputPoint!!!")
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        let private_queue = dispatch_queue_create("inputPoint", nil)
        dispatch_async(private_queue) {
            let allPoints = try! Realm().objects(Point).sorted("startDate", ascending: false)
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
            dispatch_semaphore_signal(semaphore)
        }
    }
    
    class func isSamePlace(oldPlace: Point, newPlace: CLPlacemark) -> Bool {
        let isMoved = moveDistance(oldPlace, to: newPlace) > distanceBoundary
        let isSameName = oldPlace.name == newPlace.name
        return !isMoved || isSameName
    }
    
    class func isSamePlace(oldPlace: Point, newPlace: FixedPoint) -> Bool {
        let isMoved = moveDistance(oldPlace, to: newPlace) > distanceBoundary
        let isSameName = oldPlace.name == newPlace.name
        return !isMoved || isSameName
    }
    
    class func moveDistance(oldPlace: Point, to newPlace: CLPlacemark) -> CLLocationDistance {
        
        let oldLocation = CLLocation(latitude: oldPlace.latitude, longitude: oldPlace.longitude)
        let newLocation = newPlace.location!
        let distance = newLocation.distanceFromLocation(oldLocation)
        print("distance: \(distance)m")
        
        return distance
    }
    
    class func moveDistance(oldPlace: Point, to newPlace: FixedPoint) -> CLLocationDistance {
        
        let oldLocation = CLLocation(latitude: oldPlace.latitude, longitude: oldPlace.longitude)
        let newLocation = CLLocation(latitude: newPlace.latitude, longitude: newPlace.longitude)
        let distance = newLocation.distanceFromLocation(oldLocation)
        print("distance: \(distance)m")
        
        return distance
    }
    
    
    private static func updatePoint(placemark: CLPlacemark, allPoints: Results<(Point)>) {
        let lastPoint = allPoints[0]
        
        let isSameMinute = lastPoint.endDate?.minute == NSDate().minute
        let isPast = lastPoint.endDate!.minute + pastLimitMin < NSDate().minute
        
        if !isSameMinute && !isPast {
            print("updatePoint!!!")
            try! Realm().write {
                let now = NSDate()
                let stayMin = now.minute - lastPoint.startDate!.minute
                lastPoint.endDate = now
                lastPoint.stayMin = stayMin
            }
        }
    }
    
    private static func addPoint(placemark: CLPlacemark, allPoints: Results<(Point)>) {
        print("addPoint!!!")
        let realm = try! Realm()
        
        let point = Point()
        let now = NSDate()
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
    
    class func modFavorite(id: String, select: Bool) {
        let realm = try! Realm()
        do {
            try realm.write {
                let point = realm.objects(Point).filter("id == \"\(id)\"")[0];
                point.favorite = select;
            }
        } catch {
            print("RLM ERROR!!")
        }
    }
    
}
