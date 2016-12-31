//
//  Utils.swift
//  Pogger
//
//  Created by Taiju Aoki on 2016/04/23.
//  Copyright © 2016年 Taiju Aoki. All rights reserved.
//

import Foundation

class Utils {

    static func getDayCnt(to date: Date) -> Int {

        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)

        let today = (calendar as NSCalendar).date(bySettingHour: 0, minute: 0, second: 0, of: Date(), options: .wrapComponents)!
        let date = (calendar as NSCalendar).date(bySettingHour: 0, minute: 0, second: 0, of: date, options: .wrapComponents)!

        let second = today.timeIntervalSince1970 - date.timeIntervalSince1970
        let days = second / 60 / 60 / 24

        return Int(days)
    }

    static func getDateString(for date: Date) -> String {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        let dateStr = dateFormatter.string(from: date)

        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let comps = (calendar as NSCalendar).components(.weekday, from: date)

        let dateFormatter2 = DateFormatter()
        dateFormatter2.locale = Locale(identifier: "ja")

        //comps.weekdayは 1-7の値が取得できるので-1する
        let weekDayStr = dateFormatter2.shortWeekdaySymbols[comps.weekday!-1]

        return dateStr + "(" + weekDayStr + ")"
    }

    static func getStayDateStr(_ point: Point) -> String {

        let startDate = point.startDate
        var dateText = ""

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"

        let startDateStr = dateFormatter.string(from: startDate)
        dateText += startDateStr

        return dateText
    }

    static func getAnnotationDateStr(_ point: Point) -> String {
        let date = point.startDate
        return Utils.getDateString(for: date) + String(" ") + Utils.getStayDateStr(point)
    }

    static func getShareText(_ point: Point) -> String {
        let dateStr = Utils.getShareDateStr(point)
        let address = Utils.getAddress(point)
        let encodeAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

        let ll = String(format: "%f,%f", point.latitude, point.longitude)

        let iosMapUrlStr = "http://maps.apple.com/?ll=\(ll)&q=\(encodeAddress)"
        let googleMapUrlStr = "comgooglemaps://?center=\(ll)&q=\(encodeAddress)"

        return "\(address) \(dateStr)\n[iOS Map] \(iosMapUrlStr)\n[GoogleMap] \(googleMapUrlStr)"
    }

    private static func getShareDateStr(_ point: Point) -> String {
        return getAnnotationDateStr(point)
    }

    static func getAddress(_ point: Point) -> String {
        let name = point.name ?? ""
        let subThoroughfare = point.subThoroughfare ?? ""
        let thoroughfare = point.thoroughfare ?? ""
        let subLocality = point.subLocality ?? ""
        let locality = point.locality ?? ""
        let administrativeArea = point.administrativeArea ?? ""

        var strArray = [String]()

        // 今のところ name と locality のみ表示
        if true && !name.isEmpty {
            strArray.append(name)
        }
        if false && !subThoroughfare.isEmpty {
            strArray.append(subThoroughfare)
        }
        if false && !thoroughfare.isEmpty {
            strArray.append(thoroughfare)
        }
        if false && !subLocality.isEmpty {
            strArray.append(subLocality)
        }
        if true && !locality.isEmpty {
            strArray.append(locality)
        }
        if false && !administrativeArea.isEmpty {
            strArray.append(administrativeArea)
        }
        return strArray.joined(separator: ",")
    }
}

extension Date {

    var hour: Int {
        get {
            return Calendar(identifier: .gregorian).component(.hour, from: self)
        }
    }

    var minute: Int {
        get {
            return Calendar(identifier: .gregorian).component(.minute, from: self)
        }
    }

    func isEqual(to date: Date) -> Bool {
        return self.timeIntervalSince(date) == 0
    }

    func isInSameDayAsDate(_ date: Date) -> Bool {
        return Calendar(identifier: .gregorian).isDate(self, inSameDayAs: date)
    }

}
