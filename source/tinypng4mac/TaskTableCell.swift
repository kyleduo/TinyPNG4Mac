//
//  TaskTableCell.swift
//  tinypng
//
//  Created by kyle on 16/7/1.
//  Copyright © 2016年 kyleduo. All rights reserved.
//

import Cocoa

class TaskTableCell: NSTableCellView {

	@IBOutlet weak var container: NSView!
	@IBOutlet weak var name: NSTextField!
	@IBOutlet weak var preview: NSImageView!
	@IBOutlet weak var showFinder: NSButton!
	@IBOutlet weak var progressBar: NSProgressIndicator!
	@IBOutlet weak var status: NSTextField!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		container.layer?.backgroundColor = NSColor.init(white: 0.98, alpha: 1).CGColor
		container.layer?.borderWidth = 1
		container.layer?.borderColor = NSColor.init(white: 0.8, alpha: 1).CGColor
		container.layer?.cornerRadius = 4
		
		preview.layer?.borderWidth = 1
		preview.layer?.borderColor = NSColor.init(white: 0.9, alpha: 1).CGColor
	}
	
	var task: TPTaskInfo? {
		didSet {
			self.name.stringValue = (task?.fileName)!
			self.preview.image = NSImage.init(contentsOfURL: (task?.originFile)!)
			let tastStatus = (task?.status)!
			var statusText = ""
			var progress = 0
			var display = false
			switch tastStatus {
				case .INITIAL:
					statusText = "initialed"
					progress = 1
				case .PREPARE:
					statusText = "Prepared"
					progress = 2
				case .UPLOADING:
					statusText = "Uploading"
					progress = 3
				case .PROCESSING:
					statusText = "Processing"
					progress = 4
				case .DOWNLOADING:
					statusText = "Downloading"
					progress = 5
				case .FINISH:
					statusText = "Finish"
					progress = 6
					display = true
				case .ERROR:
					statusText = "ERROR"
			}
			self.status.stringValue = statusText
			self.progressBar.doubleValue = Double(progress)
			self.showFinder.hidden = !display
		}
	}
	
	@IBAction func clickShow(sender: AnyObject) {
		NSNotificationCenter.defaultCenter().postNotification(NSNotification.init(name: "showFile", object: self.task!.outputFile!))
	}
	
	
}