//
//  TaskTableCell.swift
//  tinypng
//
//  Created by kyle on 16/7/1.
//  Copyright © 2016年 kyleduo. All rights reserved.
//

import Cocoa

class TaskTableCell: NSTableCellView {
	@IBOutlet weak var name: NSTextField!
	@IBOutlet weak var preview: NSImageView!
	@IBOutlet weak var progressBar: SpinnerProgressIndicator!
	@IBOutlet weak var status: NSTextField!
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
	var task: TPTaskInfo? {
		didSet {
			self.name.stringValue = (task?.fileName)!
			self.preview.image = NSImage.init(contentsOfURL: (task?.originFile)!)
			let taskStatus = (task?.status)!
			var statusText = ""
			var progress = 0
			switch taskStatus {
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
				case .ERROR:
					statusText = "ERROR"
			}
			
			if taskStatus == .FINISH {
				let text = "-\(Formator.formatSize(task!.originSize - task!.resultSize)) (\(Formator.formatRate(1 - task!.compressRate)))"
				self.status.stringValue = text
				self.status.textColor = NSColor(deviceRed:0.55, green:1, blue:0.65, alpha:1)
				self.name.textColor = NSColor(deviceRed:0.87, green:0.87, blue:0.87, alpha:1)
				self.name.font = NSFont.systemFontOfSize(16)
			} else if taskStatus == .ERROR {
				debugPrint(task?.errorMessage)
				self.status.stringValue = statusText
				self.status.textColor = NSColor(deviceRed:0.86, green:0.27, blue:0.26, alpha:1)
				self.name.textColor = NSColor(deviceRed:0.87, green:0.87, blue:0.87, alpha:1)
				self.name.font = NSFont.systemFontOfSize(16)
			} else {
				self.status.stringValue = statusText
				self.status.textColor = NSColor(deviceRed:0.87, green:0.87, blue:0.87, alpha:1)
				self.name.textColor = NSColor.whiteColor()
				self.name.font = NSFont.boldSystemFontOfSize(16)
			}
			
//			self.progressBar.hidden = taskStatus == .ERROR || taskStatus == .FINISH
			self.progressBar.progress = Double(progress)
		}
	}
	
}