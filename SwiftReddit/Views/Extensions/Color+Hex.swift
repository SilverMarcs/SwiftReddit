//
//  Color+Hex.swift
//  SwiftReddit
//
//  Created for flair color support
//

import SwiftUI
import Foundation

extension Color {
    /// Initialize Color from hex string
    init(hex: String) {
        let trimHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let dropHash = String(trimHex.dropFirst()).trimmingCharacters(in: .whitespacesAndNewlines)
        let hexString = trimHex.starts(with: "#") ? dropHash : trimHex
        let ui64 = UInt64(hexString, radix: 16)
        let value = ui64 != nil ? Int(ui64!) : 0
        
        // #RRGGBB
        var components = (
            R: Double((value >> 16) & 0xff) / 255,
            G: Double((value >> 08) & 0xff) / 255,
            B: Double((value >> 00) & 0xff) / 255,
            a: 1.0
        )
        
        if String(hexString).count == 8 {
            // #RRGGBBAA
            components = (
                R: Double((value >> 24) & 0xff) / 255,
                G: Double((value >> 16) & 0xff) / 255,
                B: Double((value >> 08) & 0xff) / 255,
                a: Double((value >> 00) & 0xff) / 255
            )
        }
        
        self.init(red: components.R, green: components.G, blue: components.B, opacity: components.a)
    }
}
