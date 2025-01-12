////
//  DebugViewModel.swift
//  TinyPNG4Mac
//
//  Created by kyleduo on 2025/1/12.
//

import SwiftUI

class DebugViewModel: ObservableObject {
    static let shared = DebugViewModel()

    @Published var debugMessages: [String] = []
}
