//
//  TinyPNG4MacApp.swift
//  TinyPNG4Mac
//
//  Created by kyleduo on 2024/11/16.
//

import SwiftData
import SwiftUI

@main
struct TinyPNG4MacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelgate
    @StateObject var appContext = AppContext.shared
    @StateObject var vm: MainViewModel = MainViewModel()

    @State var firstAppear: Bool = true
    @State var lastTaskCount = 0

    var body: some Scene {
        Window("", id: "") {
            MainContentView(vm: vm)
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

                    appDelgate.updateViewModel(vm: vm)

                    if let window = NSApp.windows.first {
                        appContext.updateTitleBarHeight(window: window)
                        // 不加 async 可能设置失败。这里设置会导致窗口闪一下，默认值改成获取到的 28.
                        DispatchQueue.main.async {
                            window.setContentSize(CGSize(width: appContext.minSize.width, height: appContext.minSize.height - appContext.windowTitleBarHeight))
                        }
                    }
                }
                .environmentObject(appContext)
                .onChange(of: vm.tasks.count) { value in
                    if value > 0 && self.lastTaskCount == 0 {
                        if let window = NSApp.windows.first {
                            if window.frame.size.height == appContext.minSize.height {
                                DispatchQueue.main.async {
                                    let frame = window.frame
                                    let newFrame = NSRect(origin: CGPoint(x: frame.origin.x, y: max(0, frame.origin.y - 75)), size: CGSize(width: frame.width, height: frame.height + 75))
                                    animateWindowFrame(window, newFrame: newFrame)
                                }
                            }
                        }
                    } else if value == 0 && self.lastTaskCount > 0 {
                        if let window = NSApp.windows.first {
                            DispatchQueue.main.async {
                                let frame = window.frame
                                let newFrame = NSRect(origin: CGPoint(x: frame.origin.x, y: max(0, frame.origin.y - (appContext.minSize.height - frame.height))), size: CGSize(width: appContext.minSize.width, height: appContext.minSize.height))
                                animateWindowFrame(window, newFrame: newFrame)
                            }
                        }
                    }
                    self.lastTaskCount = value
                }
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowResizability(.contentSize)
        .defaultSize(CGSize(width: 320, height: 320 - appContext.windowTitleBarHeight))

        Settings {
            SettingsView()
        }
    }

    func animateWindowFrame(_ window: NSWindow, newFrame: NSRect) {
        let animation = NSViewAnimation()
        animation.viewAnimations = [
            [
                NSViewAnimation.Key.target: window,
                NSViewAnimation.Key.startFrame: NSValue(rect: window.frame),
                NSViewAnimation.Key.endFrame: NSValue(rect: newFrame),
            ],
        ]
        animation.duration = 0.3
        animation.animationCurve = .easeOut
        animation.start()
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var vm: MainViewModel?

    func updateViewModel(vm: MainViewModel) {
        if self.vm == nil {
            self.vm = vm
        }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        FileUtils.initPaths()

        if let window = NSApp.windows.first {
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
        }
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        let imageUrls = FileUtils.findImageFiles(urls: urls)
        vm?.createTasks(imageURLs: imageUrls)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        guard let vm = vm else {
            return .terminateNow
        }

        if !vm.shouldTerminate() {
            vm.showRunnningTasksAlert()
            return .terminateCancel
        } else {
            return .terminateNow
        }
    }
}
