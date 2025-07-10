//
//  Environment++.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import Foundation
import SwiftUI

extension EnvironmentValues {
    @Entry var imageZoomNamespace: Namespace.ID?
    @Entry var onReply: ((Comment) -> Void) = { _ in
        print("No onReply passed")
    }
}
