//
//  MainViewController.swift
//  tinypng4mac
//
//  Created by kyle on 16/7/5.
//  Copyright © 2016年 kyleduo. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, NSOpenSavePanelDelegate, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate, DragContainerDelegate {
	
	@IBOutlet weak var apiKey: NSTextField!
	@IBOutlet weak var outputPathField: NSTextField!
	@IBOutlet weak var taskTableView: NSTableView!
	@IBOutlet weak var dropContainer: DragContainer!
	@IBOutlet weak var totalReduce: NSTextField!
	
	var totalSize: Double = 0
	var totalRecudeSize: Double = 0
	var keySaved = false
	
	var inputKeyAlert: InputKeyAlert?;
	
	override func viewDidLoad() {
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(MainViewController.statusChanged), name:"statusChanged", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(MainViewController.resetConfiguration), name:"resetConfiguration", object: nil)
		
		if let savedKey = TPConfig.savedkey() {
			apiKey.stringValue = savedKey
			TPClient.sApiKey = savedKey
			keySaved = true
			apiKey.editable = false
		}
		if let savedPath = TPConfig.savedPath() {
			outputPathField.stringValue = savedPath
			TPClient.sOutputPath = savedPath
			outputPathField.editable = false
		}
		
		
		totalReduce.stringValue = NSLocalizedString("0 tasks", comment: "0 tasks")
	}
	
	override func awakeFromNib() {
		dropContainer.delegate = self
		
		taskTableView.setDelegate(self)
		taskTableView.setDataSource(self)
		taskTableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyle.None
		taskTableView.enclosingScrollView?.scrollerStyle = NSScrollerStyle.Legacy
		
		apiKey.delegate = self
		outputPathField.delegate = self
	}
	
	override func viewDidAppear() {
		super.viewDidAppear()
		if TPClient.sApiKey.characters.count == 0 || TPClient.sOutputPath.characters.count == 0 {
			changePanel(true, animated: false)
			if TPClient.sApiKey.characters.count == 0 {
				self.showInputPanel()
			}
		} else {
			changePanel(false, animated: false)
		}
	}
	
	func saveApiKey(key: String) {
		TPConfig.saveKey(key)
		TPClient.sApiKey = key
		apiKey.stringValue = key
		keySaved = true
	}
	
	func saveOutputPath(path: String) {
		TPConfig.savePath(path)
		TPClient.sOutputPath = path
		outputPathField.stringValue = path
	}
	
	func showInputPanel() {
		if inputKeyAlert == nil {
			inputKeyAlert = InputKeyAlert.init()
		}
		if inputKeyAlert!.isShowing {
			return;
		}
		inputKeyAlert!.show(self.view.window!, saveAction: {(key) in
			if let k = key {
				self.saveApiKey(k)
				self.changePanel(false, animated: true)
			}
		})
	}
	
	func lockTextField() {
		apiKey.editable = false
		outputPathField.editable = false
	}
	
	func unlockTextField() {
		apiKey.editable = true
		outputPathField.editable = true
	}
	
	@objc func statusChanged(notification: NSNotification) {
		let task = notification.object as! TPTaskInfo
		if task.status == .FINISH {
			if !keySaved {
				TPConfig.saveKey(TPClient.sApiKey)
				keySaved = true
			}
			totalSize += task.originSize
			totalRecudeSize += (task.originSize - task.resultSize)
			totalReduce.stringValue = String.localizedStringWithFormat(NSLocalizedString("tasks desc", comment: "tasks desc"), TPStore.sharedStore.count(), Formator.formatSize(totalRecudeSize), Formator.formatRate(totalRecudeSize / totalSize))
			
			if TPClient.sharedClient.queue.isEmpty() {
				// all finished
				unlockTextField()
			}
		}
		
		TPStore.sharedStore.sort()
		taskTableView.reloadData()
	}
	
	@objc func resetConfiguration(notification: NSNotification) {
		TPClient.sApiKey = ""
		apiKey.stringValue = ""
		keySaved = false
		changePanel(true, animated: true)
	}
	
	@IBAction func clickSelectPath(sender: AnyObject) {
		let openPanel = NSOpenPanel();
		openPanel.title = NSLocalizedString("Select output path.", comment: "Select output path.")
		openPanel.message = NSLocalizedString("Images will put in there after compress.", comment: "Images will put in there after compress.")
		openPanel.showsResizeIndicator=true;
		openPanel.canChooseDirectories = true;
		openPanel.canChooseFiles = false;
		openPanel.allowsMultipleSelection = false;
		openPanel.canCreateDirectories = true;
		openPanel.delegate = self;
		
		openPanel.beginWithCompletionHandler { (result) -> Void in
			if(result == NSFileHandlingPanelOKButton){
				let path = openPanel.URL!.path!
				print("selected folder is \(path)");
				self.saveOutputPath(path)
			}
		}
	}
	
	@IBAction func clickSettings(sender: AnyObject) {
		let window = NSApplication.sharedApplication().windows.first!
		let height = window.frame.height
		changePanel(height == 320, animated: true)
	}
	
	@IBAction func clickFinder(sender: AnyObject) {
		NSWorkspace.sharedWorkspace().openURL(IOHeler.getOutputPath())
	}
	
	func changePanel(open: Bool, animated: Bool) {
		let window = NSApplication.sharedApplication().windows.first!
		let frame = window.frame
		let height = window.frame.height
		var t = height
		if open {
			t = 400
		} else {
			t = 320
		}
		let newFrame = CGRect.init(x: frame.origin.x, y: frame.origin.y + (height - t), width: frame.size.width, height: t)
		window.setFrame(newFrame, display: true, animate: animated)
	}
	
	func draggingEntered() {
	}
	
	func draggingExit() {
	}
	
	func draggingFileAccept(files:Array<NSURL>) {
		if TPClient.sApiKey == "" {
			showInputPanel()
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
		TPClient.sharedClient.add(tasks)
		taskTableView.reloadData()
		TPClient.sharedClient.checkExecution()
		
		apiKey.editable = false
		outputPathField.editable = false
	}
	
	func numberOfRowsInTableView(tableView: NSTableView) -> Int {
		return TPStore.sharedStore.count()
	}
	
	func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let cell = tableView.makeViewWithIdentifier("task_cell", owner: self) as? TaskTableCell
		cell!.task = TPStore.sharedStore.get(row)!
		return cell
	}
	
	override func controlTextDidEndEditing(obj: NSNotification) {
		if let textField = obj.object as? NSTextField {
			if !textField.editable {
				return;
			}
		} else {
			return;
		}
		if obj.object === self.apiKey {
			if let newKey = obj.object?.stringValue {
				if newKey != TPClient.sApiKey {
					print("newKey: " + newKey)
					saveApiKey(newKey)
				}
			}
		} else if obj.object === self.outputPathField {
			if let newOutpath = obj.object?.stringValue {
				if newOutpath != TPClient.sOutputPath {
					print("newOutpath: " + newOutpath)
					saveOutputPath(newOutpath)
				}
			}
		}
	}
}