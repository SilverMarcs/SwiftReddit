//
//  Environment++.swift
//  SwiftReddit
//
//  Created by Zabir Raihan on 18/06/2025.
//

import Foundation
import SwiftUI

extension EnvironmentValues {
    @Entry var imageZoomNamespace: Namespace.ID = Namespace().wrappedValue
    @Entry var videoNS: Namespace.ID = Namespace().wrappedValue
    @Entry var addOptimisticComment: ((String, String) -> Void) = { _, _ in
        print("No optimistic comment handler passed")
    }
}
