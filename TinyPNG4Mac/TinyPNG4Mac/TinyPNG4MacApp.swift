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
    @Environment(\.openWindow) private var openWindow

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
                    minHeight: appContext.minSize.height,
                    idealHeight: appContext.minSize.height
                )
                .onAppear {
                    if !firstAppear {
                        return
                    }
                    firstAppear = false

                    appDelgate.updateViewModel(vm: vm)
                }
                .environmentObject(appContext)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowResizability(.contentSize)
        .defaultSize(appContext.minSize)
        .commands {
            CommandGroup(replacing: CommandGroupPlacement.appInfo) {
                Button(action: {
                    // Open the "about" window
                    openWindow(id: "about")
                }, label: {
                    Text("About...")
                })
            }
        }
        
        // Note the id "about" here
        Window("About Slim Image", id: "about") {
            AboutView()
        }
        .windowResizability(.contentMinSize)

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
