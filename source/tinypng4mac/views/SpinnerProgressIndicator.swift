//
//  SpinnerProgressIndicator.swift
//  tinypng4mac
//
//  Created by kyle on 16/7/6.
//  Copyright © 2016年 kyleduo. All rights reserved.
//

import Cocoa

class SpinnerProgressIndicator: NSView {
	
	var progress: Double = 0 {
		didSet {
			self.needsDisplay = true
		}
	}
	var max: Double = 6
	var min: Double = 0
	
	var tintColor: NSColor
	
	required init?(coder: NSCoder) {
		tintColor = NSColor.whiteColor()
		
		super.init(coder: coder)
	}
	
	override func drawRect(dirtyRect: NSRect) {
		
		let size = self.bounds.size
		let diam = [size.height, size.width].minElement()!
		
		let lineWidth: CGFloat = 1
		let centerPoint = CGPointMake(size.width / 2, size.height  / 2)
		let rect = NSRect.init(
			x: centerPoint.x - diam / 2 + lineWidth / 2,
			y: centerPoint.y - diam / 2 + lineWidth / 2,
			width: diam - lineWidth,
			height: diam - lineWidth);
		let circle = NSBezierPath.init(ovalInRect: rect)
		tintColor.set()
		circle.lineWidth = lineWidth
		circle.stroke()
		
		
		let path = NSBezierPath.init()
		path.moveToPoint(centerPoint)
		
		let startAngle: Double = 90
		let endAngle = startAngle - progress / max * 360
		path.appendBezierPathWithArcWithCenter(centerPoint, radius: diam / 2 - lineWidth / 2, startAngle: CGFloat(startAngle), endAngle: CGFloat(endAngle), clockwise: true);
		path.closePath()
		path.fill()
	}
}