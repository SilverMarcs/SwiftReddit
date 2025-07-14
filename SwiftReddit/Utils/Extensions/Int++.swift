//
//  Int++.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 19/06/2025.
//

import Foundation

extension Int {
    /// Format large numbers with k suffix (e.g., 1500 -> "1.5k")
    var formatted: String {
        if abs(self) >= 1000 {
            let value = Double(self) / 1000.0
            let formatted = unsafe String(format: value.truncatingRemainder(dividingBy: 1) == 0 ? "%.0fk" : "%.1fk", value)
            return formatted
        }
        return String(self)
    }
}

extension Optional where Wrapped == Int {
    var formatted: String {
        switch self {
        case .some(let value):
            return value.formatted
        case .none:
            return "0"
        }
    }
}
