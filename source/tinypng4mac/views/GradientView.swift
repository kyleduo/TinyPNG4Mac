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
	
        let colors:[NSColor]
        if isDarkMode() {
            colors = [#colorLiteral(red: 0.1240671799, green: 0.3697319627, blue: 0.4530602098, alpha: 1),
                      #colorLiteral(red: 0.0906387195, green: 0.2567498088, blue: 0.3809036016, alpha: 1)]
        } else {
            colors = [NSColor(deviceRed:0.08, green:0.66, blue:0.84, alpha:1.00),
                      NSColor(deviceRed:0.05, green:0.47, blue:0.73, alpha:1.00)]
        }
        
		let gradient = NSGradient(colors: colors, atLocations: [0, 1], colorSpace: NSColorSpace.deviceRGB)
		gradient?.draw(in: path, angle: -90)
	}
    
    private func isDarkMode() -> Bool {
        let apperance = NSApp.effectiveAppearance
        let name = apperance.bestMatch(from: [NSAppearance.Name.aqua, NSAppearance.Name.darkAqua])
        return name == NSAppearance.Name.darkAqua
    }
}
