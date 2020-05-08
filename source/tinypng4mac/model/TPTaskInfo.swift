//
//  TPTaskInfo.swift
//  tinypng
//
//  Created by kyle on 16/6/30.
//  Copyright © 2016年 kyleduo. All rights reserved.
//

import Foundation

class TPTaskInfo: NSObject {
	var originFile: URL
	var outputFile: URL?
	var resultUrl: String
    var filePermission: NSNumber
	var fileInfo: FileInfo
	var originSize: Double
	var status: TPTaskStatus
	var progress: Progress // progress for uploading and downloading
	var compressRate: Double
	var resultSize: Double
	var uuid: String
	var errorMessage: String?
    var index: Int
	
    init(_ fileInfo: FileInfo, originSize: Double, filePermission: NSNumber?) {
        self.originFile = fileInfo.filePath
		self.fileInfo = fileInfo
		self.originSize = originSize
		
		self.status = .initial
		self.progress = Progress()
		
		self.resultUrl = ""
		self.outputFile = nil
		self.compressRate = 1
		self.resultSize = 0
		self.uuid = UUID().uuidString
		self.errorMessage = nil
        self.index = 0
        self.filePermission = filePermission != nil ? filePermission! : NSNumber(value: 0o644)
	}
    
    override var description: String {
        return String(format: "Task {}", self.fileInfo.relativePath)
    }
}

enum TPTaskStatus {
	case initial
	case prepare
	case uploading
	case processing
	case downloading
	case finish
	case error
}
