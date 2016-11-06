//
//  FixedPoint.swift
//  Pogger
//
//  Created by Taiju Aoki on 2016/07/06.
//  Copyright © 2016年 Taiju Aoki. All rights reserved.
//

import Foundation
import RealmSwift

//TODO: struct か class か検討
class FixedPoint {
    let id: String
    let startDate: Date
    let endDate: Date
    let stayMin: Int
    let longitude: Double
    let latitude: Double
    let name: String?
    let thoroughfare: String?
    let subThoroughfare: String?
    let locality: String?
    let subLocality: String?
    let postalCode: String?
    let administrativeArea: String?
    let country: String?
    let favorite: Bool
    let changed: Bool

    init(rlm: Point) {
        id = rlm.id
        startDate = rlm.startDate
        endDate = rlm.endDate
        stayMin = rlm.stayMin
        longitude = rlm.longitude
        latitude = rlm.latitude
        name = rlm.name
        thoroughfare = rlm.thoroughfare
        subThoroughfare = rlm.subThoroughfare
        locality = rlm.locality
        subLocality = rlm.subLocality
        postalCode = rlm.postalCode
        administrativeArea = rlm.administrativeArea
        country = rlm.country
        favorite = rlm.favorite
        changed = rlm.changed
    }

    func toRlmPoint() -> Point {
        let realm = try! Realm()
        return realm.objects(Point.self).filter("id == \"\(self.id)\"")[0]
    }
}
