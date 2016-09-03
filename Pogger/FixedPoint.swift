//
//  FixedPoint.swift
//  Pogger
//
//  Created by Taiju Aoki on 2016/07/06.
//  Copyright © 2016年 Taiju Aoki. All rights reserved.
//

import Foundation

//TODO: struct か class か検討
class FixedPoint {
    var id: String!
    var startDate: NSDate!
    var endDate: NSDate!
    var stayMin: Int =  0
    var longitude = 0.0
    var latitude = 0.0
    var name: String?
    var thoroughfare: String?
    var subThoroughfare: String?
    var locality: String?
    var subLocality: String?
    var postalCode: String?
    var administrativeArea: String?
    var country: String?
    var favorite = false
    var changed = false

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
}
