//
//  TinePNG4MacApp.swift
//  TinePNG4Mac
//
//  Created by 张铎 on 2024/11/16.
//

import SwiftData
import SwiftUI

@main
struct TinePNG4MacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelgate
    @StateObject var appContext = AppContext()

    @State var firstAppear: Bool = true

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(
                    minWidth: appContext.minSize.width,
                    idealWidth: appContext.minSize.width,
                    maxWidth: appContext.maxSize.width,
                    minHeight: appContext.minSize.height - appContext.windowTitleBarHeight,
                    idealHeight: appContext.minSize.height - appContext.windowTitleBarHeight
                )
                .onAppear {
                    if !firstAppear {
                        return
                    }
                    firstAppear = false

                    if let window = NSApp.windows.first {
                        appContext.updateTitleBarHeight(window: window)
                        // 不加 async 可能设置失败。这里设置会导致窗口闪一下，默认值改成获取到的 28.
                        DispatchQueue.main.async {
                            window.setContentSize(CGSize(width: 320, height: 320 - appContext.windowTitleBarHeight))
                        }
                    }
                }
                .environmentObject(appContext)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowResizability(.contentSize)
        .defaultSize(CGSize(width: 320, height: 320 - appContext.windowTitleBarHeight))
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApp.windows.first {
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
        }
    }
}
