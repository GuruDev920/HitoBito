//
//  Utilities.swift
//  Finder
//
//  Created by Tai on 6/19/20.
//  Copyright © 2020 DJay. All rights reserved.
//

import Foundation

private let dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

private func dateFormatterForLocal() -> DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = dateFormat
    dateFormatter.calendar = NSCalendar.current
    dateFormatter.timeZone = TimeZone.current
    
    return dateFormatter
}

func localToUTC(dateStr: String) -> String {
    let dateFormatter = dateFormatterForLocal()

    let dt = dateFormatter.date(from: dateStr)
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    dateFormatter.dateFormat = dateFormat

    return dateFormatter.string(from: dt!)
}

func UTCToLocal(dateStr: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = dateFormat
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

    let dt = dateFormatter.date(from: dateStr)
    dateFormatter.timeZone = TimeZone.current
    dateFormatter.dateFormat = dateFormat

    return dateFormatter.string(from: dt!)
}

func dateToString(date: Date) -> String {
    let dateFormatter = dateFormatterForLocal()
    return dateFormatter.string(from: date)
}

func stringToDate(dateStr: String) -> Date {
    let dateFormatter = dateFormatterForLocal()
    return dateFormatter.date(from: dateStr)!
}
