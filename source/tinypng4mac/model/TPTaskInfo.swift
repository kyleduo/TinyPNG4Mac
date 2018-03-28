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
	var fileName: String
	var originSize: Double
	var status: TPTaskStatus
	var progress: Progress // progress for uploading and downloading
	var compressRate: Double
	var resultSize: Double
	var uuid: String
	var errorMessage: String?
    var index: Int
	
	init(originFile: URL, fileName: String, originSize: Double) {
		self.originFile = originFile
		self.fileName = fileName
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
