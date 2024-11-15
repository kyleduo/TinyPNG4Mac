//
//  AppDelegate.swift
//  tinypng
//
//  Created by kyle on 16/6/29.
//  Copyright © 2016年 kyleduo. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}
	
	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
	}

	override func awakeFromNib() {
	}
	
	@IBAction func viewInGithub(_ sender: AnyObject) {
		NSWorkspace.shared.open(URL.init(string: "https://github.com/kyleduo/TinyPNG4Mac")!)
	}
	@IBAction func clearConfiguration(_ sender: AnyObject) {
		TPConfig.removeKey()
		NotificationCenter.default.post(name: Notification.Name(rawValue: "resetConfiguration"), object: nil)

	}
}

