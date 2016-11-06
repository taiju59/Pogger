//
//  OpenMapAppActivity.swift
//  Pogger
//
//  Created by Taiju Aoki on 2016/10/12.
//  Copyright © 2016年 Taiju Aoki. All rights reserved.
//

import UIKit

class OpenMapAppActivity: UIActivity {

    override var activityType: UIActivityType? {
        get {
            return UIActivityType("OpenMapApp")
        }
    }

    override var activityTitle: String? {
        get {
            return "地図アプリで見る"
        }
    }

    override var activityImage: UIImage? {
        get {
            return #imageLiteral(resourceName: "openMapAppIcon")
        }
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return !activityItems.filter({$0 is Point}).isEmpty
    }

    override func prepare(withActivityItems activityItems: [Any]) {

        let point = activityItems.filter({$0 is Point})[0] as! Point
        let ll = String(format: "%f,%f", point.latitude, point.longitude)
        let q = Utils.getAddress(point).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

        let urlString: String
        if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
            urlString = "comgooglemaps://?center=\(ll)&q=\(q)"
        } else {
            urlString = "http://maps.apple.com/?ll=\(ll)&q=\(q)"
        }
        let encodedUrl = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let url = URL(string: encodedUrl)!
        UIApplication.shared.openURL(url)
    }
}
