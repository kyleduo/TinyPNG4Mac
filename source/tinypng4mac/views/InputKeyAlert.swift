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
		let view = NSView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 54))
		self.input = NSTextField.init(frame: CGRect(x: 0, y: 30, width: 300, height: 24))
		self.input?.delegate = self
        self.input?.usesSingleLineMode = true
		view.addSubview(self.input!)
		let button = self.createRegisterButton()
		view.addSubview(button)
		self.accessoryView = view
		submitButton = self.addButton(withTitle: NSLocalizedString("Save", comment: "Save"))
		submitButton?.isEnabled = false
		cancelButton = self.addButton(withTitle: NSLocalizedString("Later", comment: "Later"))
	}
	
	func createRegisterButton() -> NSButton {
		let button = NSButton.init(frame: CGRect(x: 0, y: 0, width: 56, height: 24))
		button.setButtonType(NSButton.ButtonType.momentaryLight)
		button.isBordered = false
		let paragraphStyle = NSMutableParagraphStyle.init()
		paragraphStyle.alignment = NSTextAlignment.center
		let title = NSMutableAttributedString.init(string: NSLocalizedString("Register", comment: "Register"))
        title.addAttributes([NSAttributedString.Key.foregroundColor: NSColor.linkColor,
                             NSAttributedString.Key.paragraphStyle:paragraphStyle,
                             NSAttributedString.Key.underlineStyle:NSUnderlineStyle.single.rawValue], range: NSMakeRange(0, title.length))
		button.attributedTitle = title
		button.target = self
		button.action = #selector(InputKeyAlert.gotoRegister)
		return button
	}
	
	@objc func gotoRegister() {
		NSWorkspace.shared.open(URL.init(string: "https://tinypng.com/developers")!)
	}
	
	func show(_ window: NSWindow!, saveAction: ((String?) -> Void)?) {
		isShowing = true
		self.beginSheetModal(for: window, completionHandler: { (response) in
			self.isShowing = false
			if response == NSApplication.ModalResponse.alertFirstButtonReturn {
				saveAction?(self.input?.stringValue)
			}
		}) 
	}
    
    func controlTextDidChange(_ obj: Notification) {
        if let text = input?.stringValue {
            self.submitButton?.isEnabled = text.count > 0
        }
    }
}
