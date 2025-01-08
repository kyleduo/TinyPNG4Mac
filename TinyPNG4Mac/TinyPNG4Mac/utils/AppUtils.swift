//
//  AppUtils.swift
//  SubTracker
//
//  Created by kyleduo on 2024/4/7.
//

import Foundation

struct AppUtils {
    /**
     * 是否在 Preview 模式
     * @return true 是
     */
    static func isPreviewMode() -> Bool {
        #if DEBUG
            return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        #else
            return false
        #endif
    }
}
