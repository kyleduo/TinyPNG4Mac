//
//  MainWindowController.swift
//  tinypng4mac
//
//  Created by kyle on 16/7/5.
//  Copyright © 2016年 kyleduo. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {
	
	override func windowDidLoad() {
		super.windowDidLoad()
		
		if let window = self.window {
			let button = window.standardWindowButton(NSWindowButton.ZoomButton)
			button?.hidden = true
			window.titleVisibility = .Hidden
			window.titlebarAppearsTransparent = true
		}
	}
	
}
