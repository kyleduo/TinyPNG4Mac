//
//  AppContext.swift
//  TinyPNG4Mac
//
//  Created by kyleduo on 2024/11/16.
//

import SwiftUI

class AppContext: ObservableObject {
    static let shared = AppContext()

    let minSize = CGSize(width: 360, height: 440)
    let maxSize = CGSize(width: 640, height: 640)

    var appConfig = AppConfig()
    var isDebug: Bool {
        #if DEBUG
            true
        #else
            false
        #endif
    }
}
