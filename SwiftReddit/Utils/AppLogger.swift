//
//  AppLogger.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 22/06/2025.
//


import Foundation
import OSLog

enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier!
    private static let baseLogger = Logger(subsystem: subsystem, category: "api")
    
    static func info(_ message: String) {
        guard Config.shared.printDebug else { return }
        baseLogger.info("\(message)")
    }
    
    static func notice(_ message: String) {
        guard Config.shared.printDebug else { return }
        baseLogger.notice("\(message)")
    }
    
    static func trace(_ message: String) {
        guard Config.shared.printDebug else { return }
        baseLogger.trace("\(message)")
    }
    
    static func debug(_ message: String) {
        guard Config.shared.printDebug else { return }
        baseLogger.debug("\(message)")
    }
    
    static func error(_ message: String) {
//        guard Config.shared.printDebug else { return }
        baseLogger.error("\(message)")
    }
    
    static func warning(_ message: String) {
//        guard Config.shared.printDebug else { return }
        baseLogger.warning("\(message)")
    }
    
    static func critical(_ message: String) {
//        guard Config.shared.printDebug else { return }
        baseLogger.critical("\(message)")
    }
    
    static func fault(_ message: String) {
//        guard Config.shared.printDebug else { return }
        baseLogger.fault("\(message)")
    }
    
    static func log(level: OSLogType, _ message: String) {
        guard Config.shared.printDebug else { return }
        baseLogger.log(level: level, "\(message)")
    }
    
    static func logAPIResponse(_ data: Data, endpoint: String = "No endpoint") {
        guard Config.shared.printDebug else { return }
        
        guard let json = try? JSONSerialization.jsonObject(with: data),
              let prettyPrintedData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
              let prettyPrintedString = String(data: prettyPrintedData, encoding: .utf8) else {
            Self.error("Failed to pretty print API response for \(endpoint)")
            return
        }
        
        Self.info("Raw API Response for \(endpoint)\n")
        print(prettyPrintedString)     
    }
}
