// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

enum DateHelper {
    static func convertPublishedDateToReadableFormat(dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        if let date = dateFormatter.date(from: dateString) {
            return convertPublishedDateToReadableFormat(date: date)
        }
        return nil
    }
    
    static func convertPublishedDateToReadableFormat(date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date, to: Date())
        
        if let year = components.year, year >= 1 {
            return year == 1 ? "1 year ago" : "\(year) years ago"
        } else if let month = components.month, month >= 1 {
            return month == 1 ? "1 month ago" : "\(month) months ago"
        } else if let day = components.day {
            switch day {
                case 0:
                    return "Today"
                case 1:
                    return "1 day ago"
                default:
                    return "\(day) days ago"
            }
        }
        return "Today"
    }
}

