//
//  TPTools.swift
//  tinypng
//
//  Created by kyle on 16/6/30.
//  Copyright © 2016年 kyleduo. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class TPClient {
	let MAX_TASKS: Int = 5
	let BASE_URL = "https://api.tinify.com/shrink"
	
	static let sharedClient = TPClient()
	static var sApiKey = ""
	
	private init() {}
	
	let queue = TPQueue()
	let lock: NSLock = NSLock()
	var runningTasks = 0
	
	func add(tasks: [TPTaskInfo]) {
		TPStore.sharedStore.add(tasks);
		for task in tasks {
			queue.enqueue(task)
		}
	}
	
	func checkExecution() {
		lock.lock()
		while runningTasks < MAX_TASKS {
			let task = queue.dequeue()
			if let t = task {
				self.updateStatus(t, newStatus: .PREPARE)
				runningTasks += 1
				print("prepare to upload: " + t.fileName + " tasks: " + String(self.runningTasks))
				if !executeTask(t) {
					runningTasks -= 1
				}
			} else {
				break;
			}
		}
		lock.unlock()
	}
	
	func executeTask(task: TPTaskInfo) -> Bool {
		var imageData: NSData = NSData()
		do {
			let fileHandler = try NSFileHandle(forReadingFromURL:task.originFile)
			imageData = fileHandler.readDataToEndOfFile()
			
			// create url request to send
			let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: BASE_URL)!)
			mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
			
			let auth = "api:\(TPClient.sApiKey)"
			let authData = auth.dataUsingEncoding(NSUTF8StringEncoding)?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
			mutableURLRequest.setValue("Basic " + authData!, forHTTPHeaderField: "Authorization")
			
			let r = Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil)
			
			self.updateStatus(task, newStatus: .UPLOADING)
			print("uploading: " + task.fileName)
			Alamofire.upload(r.0, data: imageData)
				.progress({ (_, progress, total) in
					if progress == total {
						self.updateStatus(task, newStatus: .PROCESSING)
						print("processing: " + task.fileName)
					}
				})
				.responseJSON { response in
					let json = JSON(response.result.value!)
					if json != nil {
						let output = json["output"]
						if output != nil {
							let resultUrl = output["url"]
							task.resultUrl = String(resultUrl)
							task.resultSize = output["size"].doubleValue
							task.compressRate = task.resultSize / task.originSize
							self.onUploadFinish(task)

						} else {
							self.updateStatus(task, newStatus: .ERROR)
						}
					} else {
						self.updateStatus(task, newStatus: .ERROR)
					}
			}
			return true
		} catch {
			self.updateStatus(task, newStatus: .ERROR)
			return false
		}
	}
	
	private func onUploadFinish(task: TPTaskInfo) {
		print("downloading: " + task.fileName)
		self.updateStatus(task, newStatus: .DOWNLOADING)
		let folder = IOHeler.getOutputPath()
		task.outputFile = folder.URLByAppendingPathComponent(task.fileName)
		downloadCompressImage(task)
	}
	
	private func downloadCompressImage(task: TPTaskInfo) {Alamofire.download(.GET, task.resultUrl, destination: { temporaryURL, response in
			self.updateStatus(task, newStatus: .FINISH)
			return task.outputFile!
		})
		.response { (request, response, _, error) in
			self.runningTasks -= 1
			
			print("finish: " + task.fileName + " tasks: " + String(self.runningTasks))
			
			self.checkExecution()
		}
	}
	
	private func updateStatus(task: TPTaskInfo, newStatus: TPTaskStatus) {
		task.status = newStatus
		if newStatus == .ERROR {
			self.runningTasks -= 1
		}
		NSOperationQueue.mainQueue().addOperationWithBlock {
			NSNotificationCenter.defaultCenter().postNotificationName("statusChanged", object: task)
		}
	}
}