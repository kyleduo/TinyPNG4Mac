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

    var apiKey = ProcessInfo.processInfo.environment["API_KEY"] ?? ""
    var mockEnabled = ProcessInfo.processInfo.environment["MOCK_ENABLED"] != nil

    var maxConcurrencyCount = 1
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
                    updateStatus(.uploading, of: task)
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

            if mockEnabled {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    self.completeTask(task)
                }
                return
            }

            AF.upload(data, to: TPAPI.shrink.rawValue, headers: headers)
                .uploadProgress { progress in
                    print(progress)
                    self.updateProgress(progress.fractionCompleted, of: task)
                    self.updateStatus(.processing, of: task)
                }
                .responseDecodable(of: TPShrinkResponse.self) { response in
                    switch response.result {
                    case let .success(responseData):
                        print(response.response?.value(forHTTPHeaderField: "Compression-Count") ?? "count")
                        if let error = responseData.error {
                            let errorDescription = error + (responseData.message ?? "Unknown error")
                            print("error \(errorDescription)")
                        } else {
                            print("success \(responseData)")
                            self.downloadFile(task, response: responseData)
                        }
                    case let .failure(error):
                        print("error \(error)")
                    }
                }
        }
    }

    private func downloadFile(_ task: TaskInfo, response: TPShrinkResponse) {
        updateStatus(.downloading, of: task)
        guard let downloadUrl = task.downloadUrl else {
            failTask(task)
            return
        }

        let destination: DownloadRequest.Destination = { _, _ in
            (downloadUrl, [.removePreviousFile])
        }

        AF.download(response.output!.url, to: destination)
            .downloadProgress { progress in
                print(progress)
                self.updateProgress(progress.fractionCompleted, of: task)
            }
            .response { response in
                switch response.result {
                case .success:
                    do {
                        try downloadUrl.moveFileTo(task.originUrl)
                        if let filePermission = task.filePermission {
                            task.originUrl.setPosixPermissions(filePermission)
                        }
                        self.completeTask(task)
                    } catch {
                        debugPrint("FileManager set posixPermissions error")
                    }
                    break
                case let .failure(error):
//                    self.markError(task, errorMessage: error.errorDescription)
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

    private func completeTask(_ task: TaskInfo) {
        updateStatus(.completed, of: task)
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
        DispatchQueue.main.async {
            self.callback?.onTaskChanged(task: task.copy(status: .error, errorCode: errorCode, errorMessage: message))
        }
    }

    private func updateStatus(_ status: TaskStatus, of task: TaskInfo) {
        DispatchQueue.main.async {
            self.callback?.onTaskChanged(task: task.copy(status: status))
        }
    }

    private func updateProgress(_ progress: Double, of task: TaskInfo) {
        DispatchQueue.main.async {
            self.callback?.onTaskChanged(task: task.copy(progress: progress))
        }
    }
}

enum TPAPI: String {
    case shrink = "https://api.tinify.com/shrink"
}

protocol TPClientCallback {
    func onTaskChanged(task: TaskInfo)
}
