//
//  AppContext.swift
//  TinyPNG4Mac
//
//  Created by kyleduo on 2024/11/16.
//

import SwiftUI

class AppContext: ObservableObject {
    static let shared = AppContext()
    
    let minSize = CGSize(width: 360, height: 360)
    let maxSize = CGSize(width: 640, height: 640)

    @Published var windowTitleBarHeight: CGFloat = 28
    
    var appConfig = AppConfig()
    
    func updateTitleBarHeight(window: NSWindow) {
        windowTitleBarHeight = getTitleBarHeight(of: window)
    }

    private func getTitleBarHeight(of window: NSWindow) -> CGFloat {
        let fullHeight = window.frame.height
        let contentHeight = window.contentLayoutRect.height
        return fullHeight - contentHeight
    }
}
