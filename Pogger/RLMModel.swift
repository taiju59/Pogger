//
//  RLMModel.swift
//  Pogger
//
//  Created by Taiju Aoki on 2016/04/17.
//  Copyright © 2016年 Taiju Aoki. All rights reserved.
//

import Foundation
import RealmSwift

class Point: Object {
    
    dynamic var id: String = NSUUID().UUIDString
    dynamic var startDate: NSDate!
    dynamic var endDate: NSDate!
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
    
}

class Settings: Object {
    dynamic var showStreetView: Bool = true
    
}












