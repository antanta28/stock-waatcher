//
//  Extensions.swift
//  StockApp
//
//  Created by Kirill Fedin on 08.01.2022.
//

import Foundation
import UIKit

extension Notification.Name {
    /// Notification when symbol gets added to watchlist
    static let didAddToWatchList = Notification.Name("didAddToWatchList")
}


// MARK: - String
extension String {
    
    /// Format date from timeinverval
    /// - Parameter timeInverval: TimeInverval since 1970
    /// - Returns: Formatted String
    static func string(from timeInverval: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timeInverval)
        return DateFormatter.prettyDateFormatter.string(from: date)
    }
    
    /// Format double to string with percent style
    /// - Parameter double: Double to format
    /// - Returns: Formatter string
    static func percentage(from double: Double) -> String {
        let formatter = NumberFormatter.percentFormatter
        return formatter.string(from: NSNumber(value: double)) ?? "\(double)"
    }
    
    /// Format number to string
    /// - Parameter number: <#number description#>
    /// - Returns: <#description#>
    static func formatted(number: Double) -> String {
        let formatter = NumberFormatter.numberFormatter
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

// MARK: - DateFormatter
extension DateFormatter {
    /// Formatter for date (YYYY-MM-dd)
    static let newsDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        return formatter
    }()
    
    /// Medium date formatter
    static let prettyDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

extension NumberFormatter {
    /// Formatter for percent style
    static let percentFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    /// Formatter for decimal style
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}

// MARK: - CandleStick
extension Array where Element == CandleStick {
    func getPercentage() -> Double {
        let latestDate = self[0].date
        guard let latestClose = self.first?.close,
              let priorClose = self.first(
                where: {
                    !Calendar.current.isDate($0.date, inSameDayAs: latestDate)
                }
              )?.close else {
                  return 0.0
              }
        
        let diff = 1 - (priorClose / latestClose)
        return diff
    }
}
