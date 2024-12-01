//
//  MainViewModel.swift
//  TinyPNG4Mac
//
//  Created by kyleduo on 2024/11/17.
//

import SwiftUI
import UniformTypeIdentifiers

class MainViewModel: ObservableObject, TPClientCallback {
    @Published var tasks: [TaskInfo] = []
    @Published var monthlyUsedQuota: Int = -1
    @Published var restoreConfirmTask: TaskInfo?
    @Published var settingsNotReadyMessage: String? = nil
    @Published var showQuitWithRunningTasksAlert: Bool = false

    var totalOriginSize: UInt64 {
        tasks.reduce(0) { partialResult, task in
            partialResult + (task.originSize ?? 0)
        }
    }

    var totalFinalSize: UInt64 {
        tasks.filter { $0.status == .completed }
            .reduce(0) { partialResult, task in
                partialResult + (task.finalSize ?? 0)
            }
    }

    var completedTaskCount: Int {
        tasks.count { $0.status == .completed }
    }

    init() {
        TPClient.shared.callback = self
    }

    var failedTaskCount: Int {
        tasks.count { $0.status == .failed }
    }

    func createTasks(imageURLs: [URL]) {
        let config = AppContext.shared.appConfig
        if config.apiKey.isEmpty {
            DispatchQueue.main.async {
                self.settingsNotReadyMessage = "Please config API key first."
            }
            return
        }

        if !config.isReplaceModeEnabled && config.outputFolderUrl == nil {
            DispatchQueue.main.async {
                self.settingsNotReadyMessage = "Replace mode is disabled. Please select output folder first."
            }
            return
        }

        Task {
            for url in imageURLs {
                let originUrl = url

                if !originUrl.fileExists() {
                    let task = TaskInfo(originUrl: originUrl)
                    task.updateError(error: TaskError.from(message: "File not exists"))
                    appendTask(task: task)
                    continue
                }

                let uuid = UUID().uuidString

                let backupUrl = FileUtils.getBackupUrl(id: uuid)
                do {
                    try originUrl.copyFileTo(backupUrl)
                } catch {
                    let task = TaskInfo(originUrl: originUrl)
                    task.updateError(error: TaskError.from(error: error))
                    appendTask(task: task)
                    continue
                }

                let downloadUrl = FileUtils.getDownloadUrl(id: uuid)
                let previewImage = loadImagePreviewUsingCGImageSource(from: originUrl, maxDimension: 200)

                let fileSize: UInt64
                do {
                    fileSize = try originUrl.sizeOfFile()
                } catch {
                    let task = TaskInfo(originUrl: originUrl)
                    task.updateError(error: TaskError.from(error: error))
                    appendTask(task: task)
                    continue
                }

                let task = TaskInfo(
                    originUrl: originUrl,
                    backupUrl: backupUrl,
                    downloadUrl: downloadUrl,
                    originSize: fileSize,
                    filePermission: originUrl.posixPermissionsOfFile() ?? 0x644,
                    previewImage: previewImage ?? NSImage(named: "placeholder")!
                )

                print("Task created: \(task)")

                appendTask(task: task)

                TPClient.shared.addTask(task: task)
            }
        }
    }

    func retry(_ task: TaskInfo) {
        TPClient.shared.addTask(task: task)
    }

    func restore(_ task: TaskInfo) {
        guard task.status == .completed else {
            return
        }

        restoreConfirmTask = task
    }

    func clearAllTask() {
        TPClient.shared.stopAllTask()
        tasks.removeAll()
    }

    func clearFinishedTask() {
        tasks.removeAll { $0.status.isFinished() }
    }

    func retryAllFailedTask() {
        tasks.filter { $0.status == .failed }
            .forEach { task in
                retry(task)
            }
    }

    func restoreAll() {
        Task {
            for task in tasks {
                doRestore(task: task)
            }
        }
    }

    func restoreConfirmConfirmed() {
        guard let task = restoreConfirmTask else {
            return
        }

        defer { restoreConfirmTask = nil }

        Task {
            doRestore(task: task)
        }
    }
    
    func cancelAllTask() {
        TPClient.shared.stopAllTask()
    }
    
    func shouldTerminate() -> Bool {
        return TPClient.shared.runningTasks == 0
    }
    
    func showRunnningTasksAlert() {
        self.showQuitWithRunningTasksAlert = true
    }
    
    private func doRestore(task: TaskInfo) {
        if task.status != .completed {
            return
        }
        
        if let backupUrl = task.backupUrl {
            do {
                try backupUrl.copyFileTo(task.originUrl, override: true)
                print("restore success")
                DispatchQueue.main.async {
                    task.status = .restored
                    self.notifyTaskChanged(task: task)
                }
            } catch {
                print("restore fail \(error.localizedDescription)")
            }
        } else {
            print("backup not found")
        }
    }

    func restoreConfirmCancel() {
        restoreConfirmTask = nil
    }

    private func appendTask(task: TaskInfo) {
        DispatchQueue.main.async {
            self.tasks.append(task)
        }
    }

    private func loadImagePreviewUsingCGImageSource(from url: URL, maxDimension: CGFloat) -> NSImage? {
        // Create CGImageSource from the URL
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }

        // Get image properties to calculate aspect ratio
        guard let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any],
              let width = imageProperties[kCGImagePropertyPixelWidth] as? CGFloat,
              let height = imageProperties[kCGImagePropertyPixelHeight] as? CGFloat else {
            return nil
        }

        // Calculate aspect ratio
        let aspectRatio = width / height

        // Determine the size for the thumbnail while preserving the aspect ratio
        var thumbnailSize: CGSize
        if width > height {
            thumbnailSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else {
            thumbnailSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }

        // Create options to generate thumbnail
        let options: [CFString: Any] = [
            kCGImageSourceThumbnailMaxPixelSize: maxDimension,
            kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
        ]

        // Generate the thumbnail image
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) else {
            return nil
        }

        // Create an NSImage from the CGImage
        return NSImage(cgImage: cgImage, size: thumbnailSize)
    }

    func onTaskChanged(task: TaskInfo) {
        print("onTaskStatusChanged, \(task)")

        notifyTaskChanged(task: task)
    }

    func onMonthlyUsedQuotaUpdated(quota: Int) {
        debugPrint("onMonthlyUsedQuotaUpdated \(quota)")
        monthlyUsedQuota = quota
    }

    private func notifyTaskChanged(task: TaskInfo) {
        if let index = tasks.firstIndex(where: { item in item.id == task.id }) {
            tasks[index] = task
            sortTasksInPlace(&tasks)
        }
    }

    private func sortTasksInPlace(_ tasks: inout [TaskInfo]) {
        tasks.sort { $0 < $1 }
    }
}

struct AlertInfo {
    var type: AlertType
    var title: String
    var message: String
}

enum AlertType {
    case restoreConfirm
}
