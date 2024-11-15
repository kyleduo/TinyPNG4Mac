//
//  GradientView.swift
//  tinypng4mac
//
//  Created by kyle on 2017/5/22.
//  Copyright © 2017年 kyleduo. All rights reserved.
//

import Cocoa

class GradientView: NSView {
	override func draw(_ dirtyRect: NSRect) {
		let path = NSBezierPath()
		path.appendRect(dirtyRect)
	
		let gradient = NSGradient(colors: [NSColor(deviceRed:0.08, green:0.66, blue:0.84, alpha:1.00), NSColor(deviceRed:0.05, green:0.47, blue:0.73, alpha:1.00)], atLocations: [0, 1], colorSpace: NSColorSpace.deviceRGB)
		gradient?.draw(in: path, angle: -90)
	}
}
