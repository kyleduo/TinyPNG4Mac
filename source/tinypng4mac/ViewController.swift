//
//  ViewController.swift
//  tinypng
//
//  Created by kyle on 16/6/29.
//  Copyright © 2016年 kyleduo. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, DragContainerDelegate, NSTableViewDelegate, NSTableViewDataSource {

	@IBOutlet weak var dragContainer: DragContainer!
	@IBOutlet weak var infoPanel: NSView!
	@IBOutlet weak var fileTableView: NSTableView!
	@IBOutlet weak var reduceSize: NSTextField!
	@IBOutlet weak var reduceRate: NSTextField!
	@IBOutlet weak var noTask: NSTextField!
	@IBOutlet weak var apiKey: NSTextField!
	
	var totalSize: Double = 0
	var totalRecudeSize: Double = 0
	var keySaved = false
	
	override func viewDidLoad() {
		super.viewDidLoad()

		self.view.wantsLayer = true
		NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(ViewController.statusChanged), name:"statusChanged", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(ViewController.openInFinder), name:"showFile", object: nil)
		
		if let savedKey = KeyStore.savedkey() {
			apiKey.stringValue = savedKey
			TPClient.sApiKey = savedKey
			keySaved = true
		}
	}
	
	override func awakeFromNib() {
		self.view.layer?.backgroundColor = NSColor.init(white: 0.9, alpha: 1).CGColor
		
		dragContainer.delegate = self
		fileTableView.setDelegate(self)
		fileTableView.setDataSource(self)
		fileTableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyle.None
		fileTableView.enclosingScrollView?.scrollerStyle = NSScrollerStyle.Legacy
		
		//		infoPanel.wantsLayer = true
		infoPanel.layer?.backgroundColor = NSColor.init(white: 0.95, alpha: 1).CGColor
		infoPanel.layer?.borderWidth = 1
		infoPanel.layer?.borderColor = NSColor.init(white: 0.85, alpha: 1).CGColor
		infoPanel.layer?.cornerRadius = 4
		
		if keySaved {
			self.view.window?.makeFirstResponder(nil)
		}
	}

	override var representedObject: AnyObject? {
		didSet {
		// Update the view, if already loaded.
		}
	}
	
	@objc func statusChanged(notification: NSNotification) {
		let task = notification.object as! TPTaskInfo
		if task.status == .FINISH {
			if !keySaved {
				KeyStore.saveKey(TPClient.sApiKey)
				keySaved = true
			}
			totalSize += task.originSize
			totalRecudeSize += (task.originSize - task.resultSize)
			reduceSize.stringValue = Formator.formatSize(totalSize)
			reduceRate.stringValue = Formator.formatRate(totalRecudeSize / totalSize)
		}
		let index = TPStore.sharedStore.indexOf(task)
		if index >= 0 && index < self.numberOfRowsInTableView(self.fileTableView) {
			if let view = self.fileTableView.viewAtColumn(0, row: index, makeIfNecessary: false) as? TaskTableCell {
				view.task = task
			}
		}
	}
	
	@IBAction func registKey(sender: AnyObject) {
		NSWorkspace.sharedWorkspace().openURL(NSURL.init(string: "https://tinypng.com/developers/subscription")!)
	}
	
	@IBAction func saveKey(sender: AnyObject) {
		TPClient.sApiKey = apiKey.stringValue
		apiKey.window?.makeFirstResponder(nil)
		let alert = NSAlert.init()
		alert.addButtonWithTitle("OK")
		alert.messageText = "Now you can drag and drop files"
		alert.beginSheetModalForWindow(self.view.window!, completionHandler: nil)
	}
	
	@objc func openInFinder(file: NSURL) {
		NSWorkspace.sharedWorkspace().openURL(IOHeler.getOutputPath())
	}
	
	func draggingEntered() {
	}
	
	func draggingExit() {
	}

	
	func draggingFileAccept(files:Array<NSURL>) {
		if TPClient.sApiKey == "" {
			let alert = NSAlert.init()
			alert.addButtonWithTitle("OK")
			alert.messageText = "Please setup api key first."
			alert.beginSheetModalForWindow(self.view.window!, completionHandler: nil)
			return;
		}
		var tasks = [TPTaskInfo]()
		let manager = NSFileManager.defaultManager()
		for file in files {
			let attributes = try? manager.attributesOfItemAtPath(file.path!) //结果为AnyObject类型
			let size = attributes![NSFileSize]!
			let task = TPTaskInfo(originFile: file, fileName:file.lastPathComponent!, originSize: size.doubleValue!)
			tasks.append(task)
		}
		if tasks.count > 0 && !noTask.hidden {
			noTask.hidden = true
		}
		TPClient.sharedClient.add(tasks)
		fileTableView.reloadData()
		TPClient.sharedClient.checkExecution()
	}
	
	func numberOfRowsInTableView(tableView: NSTableView) -> Int {
		return TPStore.sharedStore.count()
	}
	
	func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let cell = tableView.makeViewWithIdentifier("task_cell", owner: self) as? TaskTableCell
		cell!.task = TPStore.sharedStore.get(row)!
		return cell
	}
	
	func tableViewSelectionDidChange(notification: NSNotification) {
		print(self.fileTableView.selectedRow)
	}
}

