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

    var apiKey: String {
        ProcessInfo.processInfo.environment["API_KEY"] ?? AppContext.shared.appConfig.apiKey
    }

    var maxConcurrencyCount: Int {
        AppContext.shared.appConfig.concurrentTaskCount
    }

    var mockEnabled = ProcessInfo.processInfo.environment["MOCK_ENABLED"] != nil

    var runningTasks = 0
    var callback: TPClientCallback?

    private var taskQueue = TPQueue<TaskInfo>()
    private let lock: NSLock = NSLock()

    private var currentRequests: [Request] = []

    func addTask(task: TaskInfo) {
        lock.withLock {
            if !taskQueue.contains(task) {
                resetStatus(of: task)
                taskQueue.enqueue(task)
            }
        }
        checkExecution()
    }

    func stopAllTask() {
        lock.withLock {
            currentRequests.forEach { request in
                request.cancel()
            }
            currentRequests.removeAll()

            taskQueue.removeAll()
            runningTasks = 0
        }
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

            updateStatus(.uploading, of: task)

            if mockEnabled {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                    self.updateStatus(.uploading, progress: 0.43237, of: task)
                }

                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double.random(in: 0.8 ..< 1.5)) {
                    self.updateStatus(.processing, of: task)
                }

                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    self.updateStatus(.downloading, of: task)
                }

                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                    self.updateStatus(.downloading, progress: 0.331983218, of: task)
                }

                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double.random(in: 5 ..< 7)) {
                    if Bool.random() {
                        self.completeTask(task, fileSizeFromResponse: 1028)
                    } else {
                        self.failTask(task, error: TaskError.apiError(statusCode: 401, message: "Unauthorised. This custom implementation provides more control"))
                    }
                }
                return
            }

            let uploadRequest = AF.upload(data, to: TPAPI.shrink.rawValue, headers: headers)
                .uploadProgress { progress in
                    if progress.fractionCompleted == 1 {
                        self.updateStatus(.processing, of: task)
                    } else {
                        self.updateStatus(.uploading, progress: progress.fractionCompleted, of: task)
                    }
                }
            currentRequests.append(uploadRequest)

            uploadRequest.responseDecodable(of: TPShrinkResponse.self) { response in
                self.currentRequests.removeAll { $0.id == uploadRequest.id }

                switch response.result {
                case let .success(responseData):
                    if let usedQuota = Int(response.response?.value(forHTTPHeaderField: TPClient.HEADER_COMPRESSION_COUNT) ?? "") {
                        self.updateUsedQuota(usedQuota)
                    }
                    if let output = responseData.output {
                        self.downloadFile(task, response: output)
                    } else if let error = responseData.error {
                        let errorDescription = error + ": " + (responseData.message ?? "Unknown error")
                        self.failTask(task, error: TaskError.apiError(statusCode: response.response?.statusCode ?? 0, message: errorDescription))
                    } else {
                        self.failTask(task, error: TaskError.apiError(statusCode: response.response?.statusCode ?? 0, message: "fail to parse response"))
                    }
                case let .failure(error):
                    self.failTask(task, error: TaskError.apiError(statusCode: response.response?.statusCode ?? 0, message: error.localizedDescription))
                }
            }
        }
    }

    private func downloadFile(_ task: TaskInfo, response output: TPShrinkResponse.Output) {
        guard let downloadUrl = task.downloadUrl else {
            failTask(task)
            return
        }

        updateStatus(.downloading, progress: 0, of: task)

        let destination: DownloadRequest.Destination = { _, _ in
            (downloadUrl, [.removePreviousFile])
        }

        let downloadRequestParams = prepareDownloadRequestParams(task: task)
        let request: DownloadRequest

        if let params = downloadRequestParams {
            var req = URLRequest(url: URL(string: output.url)!)
            req.httpMethod = HTTPMethod.post.rawValue
            req.addValue(getAuthorization(), forHTTPHeaderField: "Authorization")
            req.addValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])

            request = AF.download(req)
        } else {
            request = AF.download(output.url, to: destination)
        }

        request.downloadProgress { progress in
            print(progress)
            self.updateStatus(.downloading, progress: progress.fractionCompleted, of: task)
        }
        request.validate()

        currentRequests.append(request)

        request.response { response in
            self.currentRequests.removeAll { $0.id == request.id }
            switch response.result {
            case .success:
                do {
                    guard let presetTargetUrl = task.outputUrl else {
                        throw FileError.noOutput
                    }
                    
                    var targetUrl = presetTargetUrl
                    
                    if let contentType = response.response?.headers["Content-Type"], !(task.convertTypes?.isEmpty ?? true) {
                        if let suffix = ImageType.fromContentType(contentType: contentType)?.fileSuffix() {
                            targetUrl = presetTargetUrl.replaceSuffix(suffix: suffix)
                        }
                    }

                    let downloadedUrl: URL
                    if downloadRequestParams?.isEmpty == false {
                        try targetUrl.ensureDirectoryExists()

                        guard let afDownloadURL = response.fileURL else {
                            throw FileError.notExists
                        }
                        downloadedUrl = afDownloadURL
                    } else {
                        downloadedUrl = downloadUrl
                    }

                    try downloadedUrl.moveFileTo(targetUrl)
                    if let filePermission = task.filePermission {
                        targetUrl.setPosixPermissions(filePermission)
                    }
                    self.completeTask(task, fileSizeFromResponse: output.size)
                } catch {
                    self.failTask(task, error: error)
                }
            case let .failure(error):
                self.failTask(task, error: TaskError.apiError(statusCode: response.response?.statusCode ?? 0, message: error.localizedDescription))
            }
        }
    }

    private func prepareDownloadRequestParams(task: TaskInfo) -> [String: Any]? {
        let config = AppContext.shared.appConfig
        if !config.needPreserveMetadata() && (task.convertTypes?.isEmpty ?? true) {
            return nil
        }

        var params: [String: Any] = [:]

        var preserveList: [String] = []
        if config.preserveCopyright {
            preserveList.append("copyright")
        }
        if config.preserveCreation {
            preserveList.append("creation")
        }
        if config.preserveLocation {
            preserveList.append("location")
        }
        if !preserveList.isEmpty {
            params["preserve"] = preserveList
        }

        if let types = task.convertTypes, !types.isEmpty {
            if types.count == 1 {
                params["convert"] = [
                    "type": types[0].toContentType(),
                ]
            } else {
                let contentTypes = types.map { type in
                    type.toContentType()
                }
                params["convert"] = [
                    "type": contentTypes,
                ]
            }
        }

        return params
    }

    private func requestHeaders() -> HTTPHeaders {
        let authorization = getAuthorization()

        let headers: HTTPHeaders = [
            .authorization(authorization),
            .accept("application/json"),
        ]
        return headers
    }

    private func getAuthorization() -> String {
        let auth = "api:\(apiKey)"
        let authData = auth.data(using: String.Encoding.utf8)?.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
        let authorization = "Basic " + authData!
        return authorization
    }

    private func completeTask(_ task: TaskInfo, fileSizeFromResponse: UInt64) {
        let finalFileSize: UInt64
        do {
            finalFileSize = try task.outputUrl!.sizeOfFile()
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
        updateError(TaskError.from(error: error), of: task)
        lock.withLock {
            self.runningTasks -= 1
        }
        checkExecution()
    }

    private func updateError(_ error: TaskError, of task: TaskInfo) {
        task.status = .failed
        task.error = error
        notifyTaskUpdated(task)
    }

    private func resetStatus(of task: TaskInfo) {
        task.reset()
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
