//
//  TPTools.swift
//  tinypng
//
//  Created by kyle on 16/6/30.
//  Copyright © 2016年 kyleduo. All rights reserved.
//

import Foundation
import Alamofire

protocol TPClientCallback {
	func taskStatusChanged(task: TPTaskInfo)
}

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
	
	var callback:TPClientCallback!
	
	fileprivate init() {}
	
	let queue = TPQueue()
	let lock: NSLock = NSLock()
	var runningTasks = 0
	var finishTasksCount = 0
	
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
				debugPrint("prepare to upload: " + t.fileInfo.relativePath + " tasks: " + String(self.runningTasks))
                executeTask(t)
			} else {
				break;
			}
		}
		lock.unlock()
	}
	
	func executeTask(_ task: TPTaskInfo) {
		var imageData: Data!
		do {
			let fileHandler = try FileHandle(forReadingFrom:task.originFile as URL)
			imageData = fileHandler.readDataToEndOfFile()
			
			let auth = "api:\(TPClient.sApiKey)"
			let authData = auth.data(using: String.Encoding.utf8)?.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
			let authorizationHeader = "Basic " + authData!
			
			self.updateStatus(task, newStatus: .uploading)
			debugPrint("uploading: " + task.fileInfo.relativePath)
			
			let headers: HTTPHeaders = [
				"Authorization": authorizationHeader,
				"Accept": "application/json"
			]
			AF.upload(imageData, to: BASE_URL, method: .post, headers: headers)
				.uploadProgress(closure: { (progress) in
					if progress.fractionCompleted == 1 {
						self.updateStatus(task, newStatus: .processing)
						debugPrint("processing: " + task.fileInfo.relativePath)
					} else {
						self.updateStatus(task, newStatus: .uploading, progress: progress)
					}
				})
				.responseJSON(completionHandler: { response in
                    switch response.result {
                    case .success(let value):
                        let json = value as! [String: AnyObject]
                        if let error = json["error"] as? String {
                            debugPrint("error: " + task.fileInfo.relativePath + error)
                            self.markError(task, errorMessage: json["message"] as? String)
                            return
                        }
                        if let output = json["output"] as? [String: AnyObject] {
                            let resultUrl = output["url"] as? String ?? ""
                            task.resultUrl = resultUrl
                            task.resultSize = output["size"] as? Double ?? 0
                            task.compressRate = task.resultSize / task.originSize
                            self.onUploadFinish(task)
                        } else {
                            self.markError(task, errorMessage: "response data error")
                        }
                        
                        
                        break
                    case .failure(let error):
                        self.markError(task, errorMessage: error.errorDescription)
                        break
                    }
				})
		} catch {
			self.markError(task, errorMessage: "execute error")
		}
	}
	
	fileprivate func onUploadFinish(_ task: TPTaskInfo) {
		debugPrint("downloading: " + task.fileInfo.relativePath)
		self.updateStatus(task, newStatus: .downloading)
		if TPConfig.shouldReplace() {
			task.outputFile = task.originFile;
		} else {
			let folder = IOHeler.getOutputPath()
			task.outputFile = folder.appendingPathComponent(task.fileInfo.relativePath)
		}
		downloadCompressImage(task)
	}
	
	fileprivate func downloadCompressImage(_ task: TPTaskInfo) {
		let destination: DownloadRequest.Destination = { _, _ in
			return (task.outputFile!, [.createIntermediateDirectories, .removePreviousFile])
		}
		
        AF.download(task.resultUrl, to: destination)
			.downloadProgress(closure: { progress in
				self.updateStatus(task, newStatus: .downloading, progress: progress)
			})
			.response { response in
                switch response.result {
                case .success(_):
                    self.updateStatus(task, newStatus: .finish)
                    debugPrint("finish: " + task.fileInfo.relativePath + " tasks: " + String(self.runningTasks))
                    do {
                        try FileManager.default.setAttributes([FileAttributeKey.posixPermissions: task.filePermission], ofItemAtPath: task.fileInfo.filePath.path)
                    } catch {
                        debugPrint("FileManager set posixPermissions error")
                    }
                    break
                case .failure(let error):
                    self.markError(task, errorMessage: error.errorDescription)
                    break
                }
				
				self.checkExecution()
			}
	}
	
	fileprivate func markError(_ task: TPTaskInfo, errorMessage: String?) {
		task.errorMessage = errorMessage
		updateStatus(task, newStatus: .error)
        checkExecution()
	}
	
	fileprivate func updateStatus(_ task: TPTaskInfo, newStatus: TPTaskStatus, progress: Progress) {
		task.status = newStatus
		task.progress = progress
		if newStatus == .error || newStatus == .finish {
			self.runningTasks -= 1
			if newStatus == .finish {
				self.finishTasksCount += 1
			}
		}
		callback.taskStatusChanged(task: task)
	}
	
	fileprivate func updateStatus(_ task: TPTaskInfo, newStatus: TPTaskStatus) {
		self.updateStatus(task, newStatus: newStatus, progress: Progress())
	}
}
