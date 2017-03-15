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
			self.preview.image = NSImage.init(contentsOf: (task?.originFile)! as URL)
			let taskStatus = (task?.status)!
			var statusText = ""
			var progress = 0
			switch taskStatus {
				case .initial:
					statusText = NSLocalizedString("Initialed", comment: "Initialed")
					progress = 1
				case .prepare:
					statusText = NSLocalizedString("Prepared", comment: "Prepared")
					progress = 2
				case .uploading:
					statusText = NSLocalizedString("Uploading", comment: "Uploading")
					statusText = statusText.appendingFormat(" (%.2f%%)", (task?.progress.fractionCompleted)! * 100)
					progress = 3
				case .processing:
					statusText = NSLocalizedString("Processing", comment: "Processing")
					progress = 4
				case .downloading:
					statusText = NSLocalizedString("Downloading", comment: "Downloading")
					statusText = statusText.appendingFormat(" (%.2f%%)", (task?.progress.fractionCompleted)! * 100)
					progress = 5
				case .finish:
					statusText = NSLocalizedString("Finish", comment: "Finish")
					progress = 6
				case .error:
					statusText = NSLocalizedString("ERROR", comment: "ERROR")
			}
			
			if taskStatus == .finish {
				let text = "-\(Formator.formatSize(task!.originSize - task!.resultSize)) (\(Formator.formatRate(1 - task!.compressRate)))"
				self.status.stringValue = text
				self.status.textColor = NSColor(deviceRed:0.55, green:1, blue:0.65, alpha:1)
				self.name.textColor = NSColor(deviceRed:0.87, green:0.87, blue:0.87, alpha:1)
				self.name.font = NSFont.systemFont(ofSize: 16)
				self.finishIndicator.isHidden = false
			} else if taskStatus == .error {
				debugPrint(task?.errorMessage ?? "nil")
				self.status.stringValue = statusText
				self.status.textColor = NSColor(deviceRed:0.86, green:0.27, blue:0.26, alpha:1)
				self.name.textColor = NSColor(deviceRed:0.87, green:0.87, blue:0.87, alpha:1)
				self.name.font = NSFont.systemFont(ofSize: 16)
				self.finishIndicator.isHidden = true
			} else {
				self.status.stringValue = statusText
				self.status.textColor = NSColor(deviceRed:0.87, green:0.87, blue:0.87, alpha:1)
				self.name.textColor = NSColor.white
				self.name.font = NSFont.boldSystemFont(ofSize: 16)
				self.finishIndicator.isHidden = true
			}
			
			self.progressBar.isHidden = taskStatus == .finish
			self.progressBar.progress = Double(progress)
		}
	}
	
}
