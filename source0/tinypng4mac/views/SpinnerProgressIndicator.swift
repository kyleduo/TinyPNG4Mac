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
		tintColor = NSColor.white
		
		super.init(coder: coder)
	}
	
	override func draw(_ dirtyRect: NSRect) {
		
		let size = self.bounds.size
		let diam = [size.height, size.width].min()!
		
		let lineWidth: CGFloat = 1
		let centerPoint = CGPoint(x: size.width / 2, y: size.height  / 2)
		let rect = NSRect.init(
			x: centerPoint.x - diam / 2 + lineWidth / 2,
			y: centerPoint.y - diam / 2 + lineWidth / 2,
			width: diam - lineWidth,
			height: diam - lineWidth);
		let circle = NSBezierPath.init(ovalIn: rect)
		tintColor.set()
		circle.lineWidth = lineWidth
		circle.stroke()
		
		
		let path = NSBezierPath.init()
		path.move(to: centerPoint)
		
		let startAngle: Double = 90
		let endAngle = startAngle - progress / max * 360
		path.appendArc(withCenter: centerPoint, radius: diam / 2 - lineWidth / 2, startAngle: CGFloat(startAngle), endAngle: CGFloat(endAngle), clockwise: true);
		path.close()
		path.fill()
	}
}
