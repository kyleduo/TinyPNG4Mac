//
//  TPClient.swift
//  TinyPNG4Mac
//
//  Created by kyleduo on 2024/11/24.
//

import Alamofire
import Foundation

class TPClient {
    static let shared = TPClient()
    static let HEADER_COMPRESSION_COUNT = "Compression-Count"

    var apiKey = ProcessInfo.processInfo.environment["API_KEY"] ?? ""
    var mockEnabled = ProcessInfo.processInfo.environment["MOCK_ENABLED"] != nil

    var maxConcurrencyCount = 2
    var runningTasks = 0
    var callback: TPClientCallback?

    private var taskQueue = TPQueue<TaskInfo>()
    private let lock: NSLock = NSLock()

    func addTask(task: TaskInfo) {
        lock.withLock {
            taskQueue.enqueue(task)
        }
        checkExecution()
    }

    private func checkExecution() {
        lock.withLock {
            while runningTasks < maxConcurrencyCount {
                if let task = taskQueue.dequeue() {
                    runningTasks += 1
                    executeTask(task)
                } else {
                    break
                }
            }
        }
    }

    private func executeTask(_ task: TaskInfo) {
        do {
            guard let data = try? Data(contentsOf: task.originUrl) else {
                print("error load image data")
                return
            }

            let headers = requestHeaders()

            self.updateStatus(.uploading, of: task)

            if mockEnabled {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                    self.updateStatus(.uploading, progress: 0.47, of: task)
                }

                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    self.updateStatus(.processing, of: task)
                }

                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    self.updateStatus(.downloading, of: task)
                }

                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                    self.updateStatus(.downloading, progress: 0.38, of: task)
                }

                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int.random(in: 5 ..< 10))) {
                    self.completeTask(task, fileSizeFromResponse: 1028)
                }
                return
            }

            AF.upload(data, to: TPAPI.shrink.rawValue, headers: headers)
                .uploadProgress { progress in
                    if progress.fractionCompleted == 1 {
                        self.updateStatus(.processing, of: task)
                    } else {
                        self.updateStatus(.uploading, progress: progress.fractionCompleted, of: task)
                    }
                }
                .responseDecodable(of: TPShrinkResponse.self) { response in
                    switch response.result {
                    case let .success(responseData):
                        if let usedQuota = Int(response.response?.value(forHTTPHeaderField: TPClient.HEADER_COMPRESSION_COUNT) ?? "") {
                            self.updateUsedQuota(usedQuota)
                        }
                        if let error = responseData.error {
                            let errorDescription = error + (responseData.message ?? "Unknown error")
                            self.failTask(task, error: TaskError.apiError(message: errorDescription))
                        } else {
                            print("success \(responseData)")
                            self.downloadFile(task, response: responseData)
                        }
                    case let .failure(error):
                        self.failTask(task, error: error)
                    }
                }
        }
    }

    private func downloadFile(_ task: TaskInfo, response shrinkResponse: TPShrinkResponse) {
        guard let downloadUrl = task.downloadUrl else {
            failTask(task)
            return
        }
        guard let output = shrinkResponse.output else {
            failTask(task)
            return
        }

        updateStatus(.downloading, progress: 0, of: task)

        let destination: DownloadRequest.Destination = { _, _ in
            (downloadUrl, [.removePreviousFile])
        }

        AF.download(output.url, to: destination)
            .downloadProgress { progress in
                print(progress)
                self.updateStatus(.downloading, progress: progress.fractionCompleted, of: task)
            }
            .response { response in
                switch response.result {
                case .success:
                    do {
                        try downloadUrl.moveFileTo(task.originUrl)
                        if let filePermission = task.filePermission {
                            task.originUrl.setPosixPermissions(filePermission)
                        }
                        self.completeTask(task, fileSizeFromResponse: output.size)
                    } catch {
                        self.failTask(task, error: error)
                    }
                    break
                case let .failure(error):
                    self.failTask(task, error: error)
                    break
                }

                self.checkExecution()
            }
    }

    private func requestHeaders() -> HTTPHeaders {
        let auth = "api:\(apiKey)"
        let authData = auth.data(using: String.Encoding.utf8)?.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
        let authorizationHeader = "Basic " + authData!

        let headers: HTTPHeaders = [
            .authorization(authorizationHeader),
            .accept("application/json"),
        ]
        return headers
    }

    private func completeTask(_ task: TaskInfo, fileSizeFromResponse: UInt64) {
        let finalFileSize: UInt64
        do {
            finalFileSize = try task.originUrl.sizeOfFile()
        } catch {
            finalFileSize = fileSizeFromResponse
        }
        
        task.status = .completed
        task.finalSize = finalFileSize
        notifyTaskUpdated(task)

        lock.withLock {
            self.runningTasks -= 1
        }
        checkExecution()
    }

    private func failTask(_ task: TaskInfo, error: Error? = nil) {
        updateError(0, message: error?.localizedDescription ?? "error", of: task)
        lock.withLock {
            self.runningTasks -= 1
        }
        checkExecution()
    }

    private func updateError(_ errorCode: Int, message: String, of task: TaskInfo) {
        task.status = .error
        task.errorCode = errorCode
        task.errorMessage = message
        notifyTaskUpdated(task)
    }

    private func updateStatus(_ status: TaskStatus, of task: TaskInfo) {
        task.updateStatus(status)
        notifyTaskUpdated(task)
    }

    private func updateStatus(_ status: TaskStatus, progress: Double, of task: TaskInfo) {
        task.updateStatus(status, progress: progress)
        notifyTaskUpdated(task)
    }

    private func updateUsedQuota(_ quota: Int) {
        DispatchQueue.main.async {
            self.callback?.onMonthlyUsedQuotaUpdated(quota: quota)
        }
    }

    private func notifyTaskUpdated(_ newTask: TaskInfo) {
        DispatchQueue.main.async {
            self.callback?.onTaskChanged(task: newTask)
        }
    }
}

enum TPAPI: String {
    case shrink = "https://api.tinify.com/shrink"
}

protocol TPClientCallback {
    func onTaskChanged(task: TaskInfo)

    func onMonthlyUsedQuotaUpdated(quota: Int)
}
