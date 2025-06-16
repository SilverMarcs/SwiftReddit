////
////  URL+Extensions.swift
////  winston
////
////  Created by Winston Team on 16/06/25.
////
//
//import Foundation
//
//extension URL {
//    var queryParameters: [String: String]? {
//        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
//              let queryItems = components.queryItems else {
//            return nil
//        }
//        
//        var parameters: [String: String] = [:]
//        for item in queryItems {
//            parameters[item.name] = item.value
//        }
//        return parameters
//    }
//}
