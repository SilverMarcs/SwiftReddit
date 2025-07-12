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
        if self >= 1000 {
            return unsafe String(format: "%.1fk", Double(self) / 1000.0)
        }
        return String(self)
    }
}
