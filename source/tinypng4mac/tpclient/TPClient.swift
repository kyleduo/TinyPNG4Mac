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
	static var sOutputPath = "" {
		didSet {
			IOHeler.sOutputPath = sOutputPath
		}
	}
	
	fileprivate init() {}
	
	let queue = TPQueue()
	let lock: NSLock = NSLock()
	var runningTasks = 0
	
	func add(_ tasks: [TPTaskInfo]) {
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
				self.updateStatus(t, newStatus: .prepare)
				runningTasks += 1
				debugPrint("prepare to upload: " + t.fileName + " tasks: " + String(self.runningTasks))
				if !executeTask(t) {
					runningTasks -= 1
				}
			} else {
				break;
			}
		}
		lock.unlock()
	}
	
	func executeTask(_ task: TPTaskInfo) -> Bool {
		var imageData: Data!
		do {
			let fileHandler = try FileHandle(forReadingFrom:task.originFile as URL)
			imageData = fileHandler.readDataToEndOfFile()
			
			let auth = "api:\(TPClient.sApiKey)"
			let authData = auth.data(using: String.Encoding.utf8)?.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
			let authorizationHeader = "Basic " + authData!
			
			self.updateStatus(task, newStatus: .uploading)
			debugPrint("uploading: " + task.fileName)
			
			let headers: HTTPHeaders = [
				"Authorization": authorizationHeader,
				"Accept": "application/json"
			]
			Alamofire.upload(imageData, to: BASE_URL, method: .post, headers: headers)
				.uploadProgress(closure: { (progress) in
					if progress.fractionCompleted == 1 {
						self.updateStatus(task, newStatus: .processing)
						debugPrint("processing: " + task.fileName)
					} else {
						self.updateStatus(task, newStatus: .uploading, progress: progress)
					}
				})
				.responseJSON(completionHandler: { (response) in
                    if let value = response.result.value {
                        let json = JSON(value)
						if let error = json["error"].string {
							debugPrint("error: " + task.fileName + error)
							task.errorMessage = json["message"].string
							self.updateStatus(task, newStatus: .error)
							return
						}
						let output = json["output"]
						if output != JSON.null {
							let resultUrl = output["url"]
							task.resultUrl = String(describing: resultUrl)
							task.resultSize = output["size"].doubleValue
							task.compressRate = task.resultSize / task.originSize
							self.onUploadFinish(task)
						} else {
							task.errorMessage = "error response"
							self.updateStatus(task, newStatus: .error)
						}
					} else {
						task.errorMessage = "error response"
						self.updateStatus(task, newStatus: .error)
					}
				})
			return true
		} catch {
			task.errorMessage = "error execution"
			self.updateStatus(task, newStatus: .error)
			return false
		}
	}
	
	fileprivate func onUploadFinish(_ task: TPTaskInfo) {
		debugPrint("downloading: " + task.fileName)
		self.updateStatus(task, newStatus: .downloading)
		let folder = IOHeler.getOutputPath()
		task.outputFile = folder.appendingPathComponent(task.fileName)
		downloadCompressImage(task)
	}
	
	fileprivate func downloadCompressImage(_ task: TPTaskInfo) {
		let destination: DownloadRequest.DownloadFileDestination = { _, _ in
			return (task.outputFile!, [.createIntermediateDirectories, .removePreviousFile])
		}
		
		Alamofire.download(task.resultUrl, to: destination)
			.downloadProgress(closure: { (progress) in
				self.updateStatus(task, newStatus: .downloading, progress: progress)
			})
			.response {
				response in
				let error = response.error
				if (error != nil) {
					task.errorMessage = "error" //error?.description
					self.updateStatus(task, newStatus: .error)
				} else {
					self.updateStatus(task, newStatus: .finish)
					debugPrint("finish: " + task.fileName + " tasks: " + String(self.runningTasks))
				}
				
				self.checkExecution()
			}
	}
	
	fileprivate func updateStatus(_ task: TPTaskInfo, newStatus: TPTaskStatus, progress: Progress) {
		task.status = newStatus
		task.progress = progress
		if newStatus == .error || newStatus == .finish {
			self.runningTasks -= 1
		}
		OperationQueue.main.addOperation {
			NotificationCenter.default.post(name: Notification.Name(rawValue: "statusChanged"), object: task)
		}
	}
	
	fileprivate func updateStatus(_ task: TPTaskInfo, newStatus: TPTaskStatus) {
		self.updateStatus(task, newStatus: newStatus, progress: Progress())
	}
}
