//
//  Utils.swift
//  Pogger
//
//  Created by Taiju Aoki on 2016/04/23.
//  Copyright © 2016年 Taiju Aoki. All rights reserved.
//

import Foundation

class Utils {

    static func daysFromDate(targetDate: NSDate) -> Int {

        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!

        let today = calendar.dateBySettingHour(0, minute: 0, second: 0, ofDate: NSDate(), options: .WrapComponents)!
        let date = calendar.dateBySettingHour(0, minute: 0, second: 0, ofDate: targetDate, options: .WrapComponents)!

        let second = today.timeIntervalSince1970 - date.timeIntervalSince1970
        let days = second / 60 / 60 / 24

        return Int(days)
    }

    static func stringFromDate(date: NSDate) -> String {

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        let dateStr = dateFormatter.stringFromDate(date)

        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        let comps = calendar.components(.Weekday, fromDate: date)

        let dateFormatter2 = NSDateFormatter()
        dateFormatter2.locale = NSLocale(localeIdentifier: "ja")

        //comps.weekdayは 1-7の値が取得できるので-1する
        let weekDayStr = dateFormatter2.shortWeekdaySymbols[comps.weekday-1]

        return dateStr + "(" + weekDayStr + ")"
    }

    static func getStayDateStr(point: FixedPoint) -> String {

        let startDate = point.startDate
        let endDate = point.endDate
        var dateText = ""

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd HH:mm"

        let startDateStr = dateFormatter.stringFromDate(startDate)
        dateText += startDateStr

        if startDate.isEqualToDate(endDate) {
            return dateText
        }

        if endDate.isInSameDayAsDate(startDate) {
            let endDateStr = String(format: "%02d:%02d", endDate.hour, endDate.minute)
            dateText += " - \(endDateStr)"
            return dateText
        } else {
            let endDateStr = dateFormatter.stringFromDate(endDate)
            dateText += " - \(endDateStr)"
            return dateText
        }
    }
}
