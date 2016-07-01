//
//  TPTaskInfo.swift
//  tinypng
//
//  Created by kyle on 16/6/30.
//  Copyright © 2016年 kyleduo. All rights reserved.
//

import Foundation

class TPTaskInfo: NSObject {
	var originFile: NSURL
	var outputFile: NSURL?
	var resultUrl: String
	var fileName: String
	var originSize: Double
	var status: TPTaskStatus
	var compressRate: Double
	var resultSize: Double
	var uuid: String
	
	init(originFile: NSURL, fileName: String, originSize: Double) {
		self.originFile = originFile
		self.fileName = fileName
		self.originSize = originSize
		
		self.status = .INITIAL
		
		self.resultUrl = ""
		self.outputFile = nil
		self.compressRate = 1
		self.resultSize = 0
		self.uuid = NSUUID().UUIDString
	}
}

enum TPTaskStatus {
	case INITIAL
	case PREPARE
	case UPLOADING
	case PROCESSING
	case DOWNLOADING
	case FINISH
	case ERROR
}