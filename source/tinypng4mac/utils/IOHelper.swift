//
//  IOHelper.swift
//  tinypng4mac
//
//  Created by kyle on 16/7/1.
//  Copyright © 2016年 kyleduo. All rights reserved.
//

import Foundation

class IOHeler {
	static let sOutPutFolderName = "tinypng_output"
	
	static var sOutputPath = ""
	
	static func getOutputPath() -> NSURL {
		let fileManager = NSFileManager.defaultManager()
		var path: NSURL!
		if sOutputPath == "" {
			let directoryURL = fileManager.URLsForDirectory(.DesktopDirectory, inDomains: .UserDomainMask)[0]
			path = directoryURL.URLByAppendingPathComponent(sOutPutFolderName, isDirectory: true)
		} else {
			path = NSURL.fileURLWithPath(sOutputPath)
		}
		if !fileManager.fileExistsAtPath(path!.path!) {
			try! fileManager.createDirectoryAtURL(path!, withIntermediateDirectories: true, attributes: nil)
		}
		return path!
	}
	
	static func getDefaultOutputPath() -> NSURL {
		let fileManager = NSFileManager.defaultManager()
		let directoryURL = fileManager.URLsForDirectory(.DesktopDirectory, inDomains: .UserDomainMask)[0]
		let path = directoryURL.URLByAppendingPathComponent(sOutPutFolderName, isDirectory: true)
		return path
	}
	
	static func deleteOnExists(file: NSURL) {
		let fileManager = NSFileManager.defaultManager()
		if fileManager.fileExistsAtPath(file.path!) {
			try! fileManager.removeItemAtURL(file)
		}
	}
}