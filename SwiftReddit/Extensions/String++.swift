//
//  String++.swift
//  SwiftReddit
//
//  Created on 18/06/2025.
//

import Foundation
import SwiftUI

extension String {
    var withSubredditPrefix: String {
        return "r/\(self)"
    }
}
