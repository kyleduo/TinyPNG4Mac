//
//  DragContainer.swift
//  tinypng
//
//  Created by kyle on 16/6/30.
//  Copyright © 2016年 kyleduo. All rights reserved.
//

import Cocoa

protocol DragContainerDelegate {
	func draggingEntered();
	func draggingExit();
	func draggingFileAccept(_ files:Array<URL>);
}

class DragContainer: NSView {
	var delegate : DragContainerDelegate?
	
	let acceptTypes = ["png", "jpg", "jpeg"]
    let NSFilenamesPboardType = NSPasteboard.PasteboardType("NSFilenamesPboardType")
	
    let normalAlpha: CGFloat = 0
    let highlightAlpha: CGFloat = 0.2
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
        self.registerForDraggedTypes([
            NSPasteboard.PasteboardType.backwardsCompatibleFileURL,
            NSPasteboard.PasteboardType(rawValue: kUTTypeItem as String)
            ]);
	}
	
	override func draw(_ dirtyRect: NSRect) {
		
	}
	
	override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        self.layer?.backgroundColor = NSColor(white: 1, alpha: highlightAlpha).cgColor;
		let res = checkExtension(sender)
		if let delegate = self.delegate {
			delegate.draggingEntered();
		}
		if res {
			return NSDragOperation.generic
		}
		return NSDragOperation()
	}
	
	override func draggingExited(_ sender: NSDraggingInfo?) {
        self.layer?.backgroundColor = NSColor(white: 1, alpha: normalAlpha).cgColor;
		if let delegate = self.delegate {
			delegate.draggingExit();
		}
	}
	
	override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        self.layer?.backgroundColor = NSColor(white: 1, alpha: normalAlpha).cgColor;
		return true
	}
	
	override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
		var files = Array<URL>()
		if let board = sender.draggingPasteboard.propertyList(forType: NSFilenamesPboardType) as? NSArray {
			for path in board {
				let url = URL(fileURLWithPath: path as! String)
				let fileExtension = url.pathExtension.lowercased()
				if acceptTypes.contains(fileExtension) {
					files.append(url)
				}
			}
		}
		
		if self.delegate != nil {
			self.delegate?.draggingFileAccept(files);
		}
		
		return true
	}
	
	func checkExtension(_ draggingInfo: NSDraggingInfo) -> Bool {
        if let board = draggingInfo.draggingPasteboard.propertyList(forType: NSFilenamesPboardType) as? NSArray {
			for path in board {
				let url = URL(fileURLWithPath: path as! String)
				let fileExtension = url.pathExtension.lowercased()
				if acceptTypes.contains(fileExtension) {
					return true
				}
			}
		}
		return false
	}
}
