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
	
	static func getOutputPath() -> NSURL {
		let fileManager = NSFileManager.defaultManager()
		let directoryURL = fileManager.URLsForDirectory(.DesktopDirectory, inDomains: .UserDomainMask)[0]
		let folder = directoryURL.URLByAppendingPathComponent(sOutPutFolderName, isDirectory: true)
		if !fileManager.fileExistsAtPath(folder.path!) {
			try! fileManager.createDirectoryAtURL(folder, withIntermediateDirectories: true, attributes: nil)
		}
		return folder
	}
}