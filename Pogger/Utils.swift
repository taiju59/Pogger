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

    static func getStayDateStr(_ point: FixedPoint) -> String {

        let startDate = point.startDate!
        let endDate = point.endDate!
        var dateText = ""

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"

        let startDateStr = dateFormatter.string(from: startDate)
        dateText += startDateStr

        if startDate.isEqual(to: endDate) {
            return dateText
        }

        if endDate.isInSameDayAsDate(startDate) {
            let endDateStr = String(format: "%02d:%02d", endDate.hour, endDate.minute)
            dateText += " - \(endDateStr)"
            return dateText
        } else {
            let endDateStr = dateFormatter.string(from: endDate)
            dateText += " - \(endDateStr)"
            return dateText
        }
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
