//
//  TimestampUtils.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-01-29.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import Foundation
import Firebase

func formattedTimeFrom(timestamp: Timestamp) -> String {
    let date = timestamp.dateValue()
    let formatter = DateFormatter()
    let calendar = Calendar.current
    
    if calendar.date(Date(), matchesComponents: calendar.dateComponents([.year, .month, .day], from: date)) {
        formatter.dateFormat = "HH:mm"
    } else if calendar.date(Date(), matchesComponents: calendar.dateComponents([.year, .month], from: date)) {
        formatter.dateFormat = "MMM dd HH:mm"
    } else if calendar.date(Date(), matchesComponents: calendar.dateComponents([.year], from: date)) {
        formatter.dateFormat = "MMM dd"
    } else {
        formatter.dateFormat = "MMM dd yyyy"
    }
    return formatter.string(from: date)
}
