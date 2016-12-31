//
//  Prefix.swift
//  Pogger
//
//  Created by Taiju Aoki on 2016/05/18.
//  Copyright © 2016年 Taiju Aoki. All rights reserved.
//

import UIKit

class Prefix {
    static let themaColor = #colorLiteral(red: 0.9960784314, green: 0.2941176471, blue: 0.3921568627, alpha: 1)

    static let keypointCellType = "show_street_view"
    static let keyLocateQuality = "locate_quality"

    static let strLocateQualityHigh = "最高"
    static let strLocateQualityNormal = "普通"
    static let strLocateQualityLow = "省電力"
}

class NotificationNames {
    static let addPoint = Notification.Name(rawValue: "addPoint")
    static let updatePoint = Notification.Name(rawValue: "updatePoint")
    static let switchFavorite = Notification.Name(rawValue: "switchFavorite")
}
