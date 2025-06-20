//
//  Config.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 20/06/2025.
//

import Foundation
import Combine

class Config: ObservableObject {
    static let shared = Config()
    
    private init() { }
    
    @Published var autoplay: Bool = true
    @Published var muteOnPlay: Bool = false
}
