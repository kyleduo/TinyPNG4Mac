//
//  MainViewController.swift
//  tinypng4mac
//
//  Created by kyle on 16/7/5.
//  Copyright © 2016年 kyleduo. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, NSOpenSavePanelDelegate, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate, DragContainerDelegate, TPClientCallback {
	
	@IBOutlet weak var apiKey: NSTextField!
	@IBOutlet weak var outputPathField: NSTextField!
	@IBOutlet weak var outputPathSelectButton: NSButton!
	@IBOutlet weak var taskTableView: NSTableView!
	@IBOutlet weak var dropContainer: DragContainer!
	@IBOutlet weak var totalReduce: NSTextField!
	@IBOutlet weak var replaceSwitch: NSButton!
	@IBOutlet weak var icon: NSImageView!
	@IBOutlet weak var desc: NSTextField!
	@IBOutlet weak var background: GradientView!
	
	var totalSize: Double = 0
	var totalRecudeSize: Double = 0
	var keySaved = false
	
	var inputKeyAlert: InputKeyAlert?;
	
	// MARK: - lifecycle
	
	override func viewDidLoad() {
		NotificationCenter.default.addObserver(self, selector:#selector(MainViewController.resetConfiguration), name:NSNotification.Name(rawValue: "resetConfiguration"), object: nil)
		
		if let savedKey = TPConfig.savedkey() {
			apiKey.stringValue = savedKey
			TPClient.sApiKey = savedKey
			keySaved = true
		}
		if let savedPath = TPConfig.savedPath() {
			outputPathField.stringValue = savedPath
			TPClient.sOutputPath = savedPath
		}
		
		totalReduce.stringValue = NSLocalizedString("0 tasks", comment: "0 tasks")
		replaceSwitch.state = TPConfig.shouldReplace() ? NSControl.StateValue.on : NSControl.StateValue.off
		
		TPClient.sharedClient.callback = self
	}
	
	override func awakeFromNib() {
		dropContainer.delegate = self
		
		taskTableView.delegate = self
		taskTableView.dataSource = self
		taskTableView.selectionHighlightStyle = NSTableView.SelectionHighlightStyle.none
		taskTableView.enclosingScrollView?.scrollerStyle = NSScroller.Style.legacy
		
		apiKey.delegate = self
		outputPathField.delegate = self
	}
	
	override func viewDidAppear() {
		super.viewDidAppear()
		if TPClient.sApiKey.count == 0 || TPClient.sOutputPath.count == 0 {
			changePanel(true, animated: false)
			if TPClient.sApiKey.count == 0 {
				self.showInputPanel()
			}
		} else {
			changePanel(false, animated: false)
		}
	}
	
	// MARK: - save configuration
	
	func saveApiKey(_ key: String) {
		TPConfig.saveKey(key)
		TPClient.sApiKey = key
		apiKey.stringValue = key
		keySaved = true
	}
	
	func saveOutputPath(_ path: String) {
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
	
	func lockUI() {
		apiKey.isEditable = false
		outputPathField.isEditable = false
		replaceSwitch.isEnabled = false
		outputPathSelectButton.isEnabled = false
	}
	
	func unlockUI() {
		apiKey.isEditable = true
		replaceSwitch.isEnabled = true
		outputPathSelectButton.isEnabled = true
		
		outputPathField.isEditable = !TPConfig.shouldReplace()
	}
	
	// MARK: - tpclient callback
	
	func taskStatusChanged(task: TPTaskInfo) {
		if task.status == .finish {
			if !keySaved {
				TPConfig.saveKey(TPClient.sApiKey)
				keySaved = true
			}
			totalSize += task.originSize
			totalRecudeSize += (task.originSize - task.resultSize)
			totalReduce.stringValue = String.localizedStringWithFormat(NSLocalizedString("tasks desc", comment: "tasks desc"), TPClient.sharedClient.finishTasksCount, Formator.formatSize(totalRecudeSize), Formator.formatRate(totalRecudeSize / totalSize))
			
			if TPClient.sharedClient.queue.isEmpty() {
				// all finished
				unlockUI()
			}
		}
		
		TPStore.sharedStore.sort()
		taskTableView.reloadData()
	}
	
	// MARK: - notification
	
	@objc func resetConfiguration(_ notification: Notification) {
		TPClient.sApiKey = ""
		apiKey.stringValue = ""
		apiKey.isEditable = true
		keySaved = false
		changePanel(true, animated: true)
	}
	
	// MARK: - ui action
	
	@IBAction func clickSelectPath(_ sender: AnyObject) {
		let openPanel = NSOpenPanel();
		openPanel.title = NSLocalizedString("Select output path.", comment: "Select output path.")
		openPanel.message = NSLocalizedString("Images will put in there after compress.", comment: "Images will put in there after compress.")
		openPanel.showsResizeIndicator=true;
		openPanel.canChooseDirectories = true;
		openPanel.canChooseFiles = false;
		openPanel.allowsMultipleSelection = false;
		openPanel.canCreateDirectories = true;
		openPanel.delegate = self;
		
		openPanel.begin { (result) -> Void in
			if(result.rawValue == NSFileHandlingPanelOKButton){
				let path = openPanel.url!.path
				debugPrint("selected folder is \(path)");
				self.saveOutputPath(path)
			}
		}
	}
	
	@IBAction func clickSettings(_ sender: AnyObject) {
		let window = NSApplication.shared.windows.first!
		let height = window.frame.height
		changePanel(height == 320, animated: true)
	}
	
	@IBAction func clickFinder(_ sender: AnyObject) {
		NSWorkspace.shared.open(IOHeler.getOutputPath() as URL)
	}
    
    @IBAction func clickRetry(_ sender: AnyObject) {
        TPClient.sharedClient.checkErrorsToRetry()
        lockUI()
    }
	
	func changePanel(_ open: Bool, animated: Bool) {
		let window = NSApplication.shared.windows.first!
		let frame = window.frame
		let height = window.frame.height
		var target = height
		if open {
			target = 417
		} else {
			target = 320
		}
		if frame.size.height == target {
			return
		}
		let newFrame = CGRect.init(x: frame.origin.x, y: frame.origin.y + (height - target), width: frame.size.width, height: target)
		window.setFrame(newFrame, display: true, animate: animated)
	}
	
	@IBAction func clickReplaceSwitch(_ sender: NSButton) {
		let isOn = sender.state == NSControl.StateValue.on
		TPConfig.saveReplace(isOn)
		outputPathField.isEditable = !isOn
	}
	
	// MARK: - dragging
	
	func draggingEntered() {
	}
	
	func draggingExit() {
	}
	
	func draggingFileAccept(_ files:Array<FileInfo>) {
		if TPClient.sApiKey == "" {
			showInputPanel()
			return;
		}
		var tasks = [TPTaskInfo]()
		let manager = FileManager.default
		for file in files {
            print(file.filePath.path)
            print(file.filePath.relativePath)
            let attributes = try? manager.attributesOfItem(atPath: file.filePath.path)
			let size = attributes![FileAttributeKey.size]!
			let task = TPTaskInfo(file, originSize: (size as AnyObject).doubleValue!)
			tasks.append(task)
		}
		TPClient.sharedClient.add(tasks)
		taskTableView.reloadData()
		TPClient.sharedClient.checkExecution()
		
		icon.animator().alphaValue = 0
		desc.animator().alphaValue = 0
		
		lockUI()
		changePanel(false, animated: true)
	}
	
	// MARK: - tableview
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		return TPStore.sharedStore.count()
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "task_cell"), owner: self) as? TaskTableCell
		cell!.task = TPStore.sharedStore.get(row)!
		return cell
	}
	
	// MARK: - textfield
	
	func controlTextDidEndEditing(_ obj: Notification) {
		if let textField = obj.object as? NSTextField {
			if !textField.isEditable {
				return;
			}
			let value = textField.stringValue
			if textField == self.apiKey {
				let newKey = value
				if newKey != TPClient.sApiKey && newKey != "" {
					debugPrint("newKey: " + newKey)
					saveApiKey(newKey)
					if TPClient.sOutputPath != "" {
						self.changePanel(false, animated: true)
					}
				}
			} else if textField == self.outputPathField {
				let newOutpath = value
				if newOutpath != TPClient.sOutputPath && newOutpath != "" {
					debugPrint("newOutpath: " + newOutpath)
					saveOutputPath(newOutpath)
				}
			}
		} else {
			return;
		}
	}
}
