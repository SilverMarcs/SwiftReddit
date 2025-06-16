//
//  AppPreferences.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 17/06/2025.
//

import Foundation
import Combine

class AppPreferences: ObservableObject {
    static let shared = AppPreferences()
    
    private init() {}

    var hasLaunched: Bool = false
}
