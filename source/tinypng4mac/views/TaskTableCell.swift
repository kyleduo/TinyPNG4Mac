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
	@IBOutlet weak var finishIndicator: NSImageView!
	
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
					statusText = NSLocalizedString("Initialed", comment: "Initialed")
					progress = 1
				case .PREPARE:
					statusText = NSLocalizedString("Prepared", comment: "Prepared")
					progress = 2
				case .UPLOADING:
					statusText = NSLocalizedString("Uploading", comment: "Uploading")
					progress = 3
				case .PROCESSING:
					statusText = NSLocalizedString("Processing", comment: "Processing")
					progress = 4
				case .DOWNLOADING:
					statusText = NSLocalizedString("Downloading", comment: "Downloading")
					progress = 5
				case .FINISH:
					statusText = NSLocalizedString("Finish", comment: "Finish")
					progress = 6
				case .ERROR:
					statusText = NSLocalizedString("ERROR", comment: "ERROR")
			}
			
			if taskStatus == .FINISH {
				let text = "-\(Formator.formatSize(task!.originSize - task!.resultSize)) (\(Formator.formatRate(1 - task!.compressRate)))"
				self.status.stringValue = text
				self.status.textColor = NSColor(deviceRed:0.55, green:1, blue:0.65, alpha:1)
				self.name.textColor = NSColor(deviceRed:0.87, green:0.87, blue:0.87, alpha:1)
				self.name.font = NSFont.systemFontOfSize(16)
				self.finishIndicator.hidden = false
			} else if taskStatus == .ERROR {
				debugPrint(task?.errorMessage)
				self.status.stringValue = statusText
				self.status.textColor = NSColor(deviceRed:0.86, green:0.27, blue:0.26, alpha:1)
				self.name.textColor = NSColor(deviceRed:0.87, green:0.87, blue:0.87, alpha:1)
				self.name.font = NSFont.systemFontOfSize(16)
				self.finishIndicator.hidden = true
			} else {
				self.status.stringValue = statusText
				self.status.textColor = NSColor(deviceRed:0.87, green:0.87, blue:0.87, alpha:1)
				self.name.textColor = NSColor.whiteColor()
				self.name.font = NSFont.boldSystemFontOfSize(16)
				self.finishIndicator.hidden = true
			}
			
			self.progressBar.hidden = taskStatus == .FINISH
			self.progressBar.progress = Double(progress)
		}
	}
	
}