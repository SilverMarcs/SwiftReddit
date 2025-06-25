//
//  Config.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 20/06/2025.
//

import Foundation
import SwiftUI
import Combine

class Config: ObservableObject {
    static let shared = Config()
    
    @AppStorage("autoplay") var autoplay: Bool = true
    @AppStorage("muteOnPlay") var muteOnPlay: Bool = false
    
    @AppStorage("allowNSFW") var allowNSFW: Bool = false
    
    @AppStorage("printDebug") var printDebug: Bool = false
    
    private init() { }
}
