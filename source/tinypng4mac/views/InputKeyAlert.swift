//
//  InputKeyAlert.swift
//  tinypng4mac
//
//  Created by kyle on 16/7/7.
//  Copyright © 2016年 kyleduo. All rights reserved.
//

import Cocoa

class InputKeyAlert: NSAlert, NSTextFieldDelegate {
	
	var input: NSTextField?
	var submitButton: NSButton?
	var cancelButton: NSButton?
	var isShowing = false
	
	override init() {
		super.init()
		
		self.messageText = NSLocalizedString("Input developer API Key. If you do not have, click register button.", comment: "Input developer API Key. If you do not have, click register button.")
		let view = NSView.init(frame: CGRectMake(0, 0, 300, 54))
		self.input = NSTextField.init(frame: CGRectMake(0, 30, 300, 24))
		self.input?.delegate = self
		view.addSubview(self.input!)
		let button = self.createRegisterButton()
		view.addSubview(button)
		self.accessoryView = view
		submitButton = self.addButtonWithTitle(NSLocalizedString("Save", comment: "Save"))
		submitButton?.enabled = false
		cancelButton = self.addButtonWithTitle(NSLocalizedString("Later", comment: "Later"))
	}
	
	func createRegisterButton() -> NSButton {
		let button = NSButton.init(frame: CGRectMake(0, 0, 56, 24))
		button.setButtonType(NSButtonType.MomentaryLightButton)
		button.bordered = false
		let paragraphStyle = NSMutableParagraphStyle.init()
		paragraphStyle.alignment = NSTextAlignment.Center
		let title = NSMutableAttributedString.init(string: NSLocalizedString("Register", comment: "Register"))
		title.addAttributes([NSForegroundColorAttributeName: NSColor.blueColor(),
			NSParagraphStyleAttributeName:paragraphStyle,
			NSUnderlineStyleAttributeName:NSUnderlineStyle.StyleSingle.rawValue], range: NSMakeRange(0, title.length))
		button.attributedTitle = title
		button.target = self
		button.action = #selector(InputKeyAlert.gotoRegister)
		return button
	}
	
	func gotoRegister() {
		NSWorkspace.sharedWorkspace().openURL(NSURL.init(string: "https://tinypng.com/developers/subscription")!)
	}
	
	func show(window: NSWindow!, saveAction: ((String?) -> Void)?) {
		isShowing = true
		self.beginSheetModalForWindow(window) { (response) in
			self.isShowing = false
			if response == NSAlertFirstButtonReturn {
				saveAction?(self.input?.stringValue)
			}
		}
	}
	
	override func controlTextDidChange(obj: NSNotification) {
		if let text = input?.stringValue {
			self.submitButton?.enabled = text.characters.count > 0
		}
	}
}
