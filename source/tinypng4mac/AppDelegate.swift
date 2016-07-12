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
	
	func applicationDidFinishLaunching(aNotification: NSNotification) {
		// Insert code here to initialize your application
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}
	
	func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
		return true
	}

	override func awakeFromNib() {
	}
	
	@IBAction func viewInGithub(sender: AnyObject) {
		NSWorkspace.sharedWorkspace().openURL(NSURL.init(string: "https://github.com/kyleduo/TinyPNG4Mac")!)
	}
	@IBAction func clearConfiguration(sender: AnyObject) {
		TPConfig.removeKey()
		NSNotificationCenter.defaultCenter().postNotificationName("resetConfiguration", object: nil)

	}
}

