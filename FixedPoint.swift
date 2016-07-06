//
//  FixedPoint.swift
//  Pogger
//
//  Created by Taiju Aoki on 2016/07/06.
//  Copyright © 2016年 Taiju Aoki. All rights reserved.
//

import Foundation

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
    
    class func fixedPointFromRlm(rlm: Point) -> FixedPoint {
        let fixedPoint = FixedPoint()
        fixedPoint.id = rlm.id
        fixedPoint.startDate = rlm.startDate
        fixedPoint.endDate = rlm.endDate
        fixedPoint.stayMin = rlm.stayMin
        fixedPoint.longitude = rlm.longitude
        fixedPoint.latitude = rlm.latitude
        fixedPoint.name = rlm.name
        fixedPoint.thoroughfare = rlm.thoroughfare
        fixedPoint.subThoroughfare = rlm.subThoroughfare
        fixedPoint.locality = rlm.locality
        fixedPoint.subLocality = rlm.subLocality
        fixedPoint.postalCode = rlm.postalCode
        fixedPoint.administrativeArea = rlm.administrativeArea
        fixedPoint.country = rlm.country
        fixedPoint.favorite = rlm.favorite
        fixedPoint.changed = rlm.changed
        
        return fixedPoint
    }
}