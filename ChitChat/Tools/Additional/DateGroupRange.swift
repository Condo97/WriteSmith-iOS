//
//  DateGroupRange.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/20/23.
//

import Foundation

enum DateGroupRange: CaseIterable {
    
    case today
    case yesterday
    case thisWeek
    case lastWeek
    case lastThirtyDays
    case older
    
    static var ordered: [DateGroupRange] = [
        .today,
        .yesterday,
        .thisWeek,
        .lastWeek,
        .lastThirtyDays,
        .older
    ]
    
    var displayString: String {
        switch self {
        case .today:
            return "Today"
        case .yesterday:
            return "Yesterday"
        case .thisWeek:
            return "This Week"
        case .lastWeek:
            return "Last Week"
        case .lastThirtyDays:
            return "This Month"
        case .older:
            return "Older"
        }
    }
    
    var range: Range<Int>? {
        switch self {
        case .today:
            return 0..<1
        case .yesterday:
            return 1..<2
        case .thisWeek:
            return 2..<7
        case .lastWeek:
            return 7..<14
        case .lastThirtyDays:
            return 14..<30
        case .older:
            return nil
        }
    }
    
    static func get(fromDaysAgo: Int) -> DateGroupRange? {
        for dateGroupRange in DateGroupRange.allCases {
            if dateGroupRange.range != nil && dateGroupRange.range!.contains(fromDaysAgo) {
                return dateGroupRange
            }
        }
        
        return DateGroupRange.older
    }
    
}
