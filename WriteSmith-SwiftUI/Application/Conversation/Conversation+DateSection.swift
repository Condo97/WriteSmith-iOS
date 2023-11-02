//
//  Conversation+DateSection.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/22/23.
//

import Foundation

extension Conversation {
    
    @objc
    var dateSection: String {
        return "Today"
        
        if let latestChatDate = latestChatDate {
            if daysAgo(from: latestChatDate) <= 0 {
                return "Today"
            } else if daysAgo(from: latestChatDate) <= 1 {
                return "Yesterday"
            } else if daysAgo(from: latestChatDate) <= 7 {
                return "This Week"
            } else if daysAgo(from: latestChatDate) <= 14 {
                return "Last Week"
            } else if daysAgo(from: latestChatDate) <= 30 {
                return "This Month"
            } else if daysAgo(from: latestChatDate) <= 60 {
                return "Last Month"
            } else {
                return "Older"
            }
        }
        
        return "Unknown"
    }
    
    private func daysAgo(from date: Date) -> Int {
        Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 99
    }
    
}
