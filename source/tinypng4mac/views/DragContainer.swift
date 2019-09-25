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
	func draggingFileAccept(_ files:Array<FileInfo>);
}

class DragContainer: NSView {
	var delegate : DragContainerDelegate?
	
	let acceptTypes = ["png", "jpg", "jpeg"]
    let NSFilenamesPboardType = NSPasteboard.PasteboardType("NSFilenamesPboardType")
	
    let normalAlpha: CGFloat = 0
    let highlightAlpha: CGFloat = 0.2
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
        self.registerForDraggedTypes([
            NSPasteboard.PasteboardType.backwardsCompatibleFileURL,
            NSPasteboard.PasteboardType(rawValue: kUTTypeItem as String)
            ]);
	}
	
	override func draw(_ dirtyRect: NSRect) {
		
	}
	
	override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        self.layer?.backgroundColor = NSColor(white: 1, alpha: highlightAlpha).cgColor;
		if let delegate = self.delegate {
			delegate.draggingEntered();
		}
        return NSDragOperation.generic
	}
	
	override func draggingExited(_ sender: NSDraggingInfo?) {
        self.layer?.backgroundColor = NSColor(white: 1, alpha: normalAlpha).cgColor;
		if let delegate = self.delegate {
			delegate.draggingExit();
		}
	}
	
	override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        self.layer?.backgroundColor = NSColor(white: 1, alpha: normalAlpha).cgColor;
		return true
	}
	
	override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
		var files = Array<FileInfo>()
        if let board = sender.draggingPasteboard.propertyList(forType: NSFilenamesPboardType) as? NSArray {
			for path in board {
                files.append(contentsOf: collectFiles(path as! String))
			}
		}
		
		if self.delegate != nil {
			self.delegate?.draggingFileAccept(files);
		}
		
		return true
	}
    
    func collectFiles(_ filePath: String) -> Array<FileInfo> {
        var files = Array<FileInfo>()
        let isDirectory = IOHeler.isDirectory(filePath)
        if isDirectory {
            let fileManager = FileManager.default
            let enumerator = fileManager.enumerator(atPath: filePath)
            while let relativePath = enumerator?.nextObject() as? String {
                let fullFilePath = filePath.appending("/\(relativePath)")
                if (fileIsAcceptable(fullFilePath)) {
                    let parent = URL(fileURLWithPath: filePath).lastPathComponent
                    files.append(FileInfo(URL(fileURLWithPath: fullFilePath), relativePath:"\(parent)/\(relativePath)"))
                }
            }
        } else if (fileIsAcceptable(filePath)) {
            let url = URL(fileURLWithPath: filePath)
            files.append(FileInfo(url, relativePath:url.lastPathComponent))
        }
        return files
    }
    
    func fileIsAcceptable(_ path: String) -> Bool {
        let url = URL(fileURLWithPath: path)
        let fileExtension = url.pathExtension.lowercased()
        return acceptTypes.contains(fileExtension)
    }
}
