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
	func draggingFileAccept(files:Array<NSURL>);
}

class DragContainer: NSView {
	var delegate : DragContainerDelegate?
	
	let acceptTypes = ["png"]
	
	let normalColor: CGFloat = 0.95
	let highlightColor: CGFloat = 0.99
	let borderColor: CGFloat = 0.85
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.registerForDraggedTypes([NSFilenamesPboardType, NSURLPboardType, NSPasteboardTypeTIFF]);
		self.layer?.backgroundColor = NSColor(white: normalColor, alpha: 1).CGColor;
		self.layer?.borderWidth = 1;
		self.layer?.borderColor = NSColor(white: borderColor, alpha: 1).CGColor;
		self.layer?.cornerRadius = 4;
	}
	
	override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
		self.layer?.backgroundColor = NSColor(white: highlightColor, alpha: 1).CGColor;
		let res = checkExtension(sender)
		if let delegate = self.delegate {
			delegate.draggingEntered();
		}
		if res {
			return NSDragOperation.Generic
		}
		return NSDragOperation.None
	}
	
	override func draggingExited(sender: NSDraggingInfo?) {
		self.layer?.backgroundColor = NSColor(white: normalColor, alpha: 1).CGColor;
		if let delegate = self.delegate {
			delegate.draggingExit();
		}
	}
	
	override func prepareForDragOperation(sender: NSDraggingInfo) -> Bool {
		self.layer?.backgroundColor = NSColor(white: normalColor, alpha: 1).CGColor;
		return true
	}
	
	override func performDragOperation(sender: NSDraggingInfo) -> Bool {
		var files = Array<NSURL>()
		if let board = sender.draggingPasteboard().propertyListForType(NSFilenamesPboardType) as? NSArray {
			for path in board {
				let url = NSURL(fileURLWithPath: path as! String)
				if let fileExtension = url.pathExtension?.lowercaseString {
					if acceptTypes.contains(fileExtension) {
						files.append(url)
					}
				}
			}
		}
		
		if self.delegate != nil {
			self.delegate?.draggingFileAccept(files);
		}
		
		return true
	}
	
	func checkExtension(draggingInfo: NSDraggingInfo) -> Bool {
		if let board = draggingInfo.draggingPasteboard().propertyListForType(NSFilenamesPboardType) as? NSArray {
			for path in board {
				let url = NSURL(fileURLWithPath: path as! String)
				if let fileExtension = url.pathExtension?.lowercaseString {
					if acceptTypes.contains(fileExtension) {
						return true
					}
				}
			}
		}
		return false
	}

}
