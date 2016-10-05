//
//  LocationInfo.swift
//  Pogger
//
//  Created by Taiju Aoki on 2016/07/11.
//  Copyright © 2016年 Taiju Aoki. All rights reserved.
//

import Foundation
import CoreLocation
import RealmSwift

class LocationInfo: Object {

    dynamic var timestamp: Date!
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
}
