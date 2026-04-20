//
//  ImageTask.swift
//  TinyPNG4Mac
//
//  Created by kyleduo on 2024/11/17.
//
import Foundation
import SwiftUI

/// Image compression task
class TaskInfo: Identifiable {
    var id: String
    var originUrl: URL
    /// Selected file or root folder from which the origin image is discovered.
    var inputUrl: URL
    var filePermission: Int?
    var previewImage: NSImage?
    var backupUrl: URL?
    var downloadUrl: URL?
    var outputUrl: URL?
    /// Optional task-specific save mode. Falls back to global settings when nil.
    var saveMode: String?
    /// Optional task-specific output directory. Falls back to global settings when nil.
    var outputDirectoryUrl: URL?
    /// types to convert the image to
    /// If nil or empty, do not convert. If provide multiple image types, the smallest one will be used.
    var convertTypes: [ImageType]?
    var status: TaskStatus
    /// in byte
    var originSize: UInt64?
    /// Compressed image size
    /// in byte
    var finalSize: UInt64?
    /// The final output type. If multiple image types provided, the smallest one will be used.
    /// This depends on the api service.
    var outputType: ImageType?
    var error: TaskError?
    /// upload / download progress
    var progress: Double = 0

    init(
        id: String,
        originUrl: URL,
        inputUrl: URL? = nil,
        status: TaskStatus,
        filePermission: Int? = nil,
        previewImage: NSImage? = nil,
        backupUrl: URL? = nil,
        downloadUrl: URL? = nil,
        outputUrl: URL? = nil,
        saveMode: String? = nil,
        outputDirectoryUrl: URL? = nil,
        originSize: UInt64? = nil,
        finalSize: UInt64? = nil,
        error: TaskError? = nil,
        progress: Double = 0
    ) {
        self.id = id
        self.originUrl = originUrl
        self.inputUrl = inputUrl ?? originUrl
        self.status = status
        self.filePermission = filePermission
        self.previewImage = previewImage
        self.backupUrl = backupUrl
        self.downloadUrl = downloadUrl
        self.outputUrl = outputUrl
        self.saveMode = saveMode
        self.outputDirectoryUrl = outputDirectoryUrl
        self.originSize = originSize
        self.finalSize = finalSize
        self.error = error
        self.progress = progress
    }

    init(originUrl: URL, inputUrl: URL, backupUrl: URL, downloadUrl: URL, outputUrl: URL? = nil, originSize: UInt64, filePermission: Int, previewImage: NSImage, saveMode: String? = nil, outputDirectoryUrl: URL? = nil, convertTypes: [ImageType]? = nil) {
        id = UUID().uuidString
        status = .created
        self.previewImage = previewImage
        self.originUrl = originUrl
        self.inputUrl = inputUrl
        self.backupUrl = backupUrl
        self.downloadUrl = downloadUrl
        self.outputUrl = outputUrl
        self.originSize = originSize
        self.filePermission = filePermission
        self.saveMode = saveMode
        self.outputDirectoryUrl = outputDirectoryUrl
        self.convertTypes = convertTypes
    }

    init(originUrl: URL) {
        id = UUID().uuidString
        self.originUrl = originUrl
        inputUrl = originUrl
        filePermission = nil
        backupUrl = nil
        downloadUrl = nil
        outputUrl = nil
        saveMode = nil
        outputDirectoryUrl = nil
        status = .created
        originSize = 0
        finalSize = 0
        previewImage = nil
    }
}

extension TaskInfo: CustomStringConvertible {
    var description: String {
        return "Task(id: \(id), status: \(status), originUrl: \(originUrl.path(percentEncoded: false))"
    }
}

extension TaskInfo: Equatable {
    static func == (lhs: TaskInfo, rhs: TaskInfo) -> Bool {
        return lhs.id == rhs.id &&
            lhs.originUrl == rhs.originUrl &&
            lhs.status == rhs.status &&
            lhs.progress == rhs.progress &&
            lhs.error == rhs.error
    }
}

extension TaskInfo {
    func effectiveSaveMode(config: AppConfig = AppContext.shared.appConfig) -> String {
        if let saveMode, AppConfig.saveModeKeys.contains(saveMode) {
            return saveMode
        }
        return config.saveMode
    }

    func effectiveOutputDirectoryUrl(config: AppConfig = AppContext.shared.appConfig) -> URL? {
        outputDirectoryUrl ?? config.outputDirectoryUrl
    }

    func resolveOutputUrl(config: AppConfig = AppContext.shared.appConfig) -> URL? {
        if effectiveSaveMode(config: config) == AppConfig.saveModeNameOverwrite {
            return originUrl
        }

        guard let targetDirectory = effectiveOutputDirectoryUrl(config: config) else {
            return nil
        }

        let relocatedUrl = FileUtils.getRelocatedRelativePath(of: originUrl, fromDir: inputUrl, toDir: targetDirectory)
        return relocatedUrl ?? targetDirectory.appendingPathComponent(originUrl.lastPathComponent)
    }

    func updateError(error: TaskError) {
        status = .failed
        self.error = error
    }

    func updateStatus(_ newStatus: TaskStatus, progress: Double? = nil) {
        status = newStatus
        if let progress {
            self.progress = progress
        }
    }

    func reset() {
        status = .created
        error = nil
        finalSize = nil
        progress = 0
    }
}

extension TaskInfo: Comparable {
    static func < (lhs: TaskInfo, rhs: TaskInfo) -> Bool {
        // Define the precedence of each status
        let precedence: [TaskStatus: Int] = [
            .failed: 0,
            .uploading: 1,
            .processing: 1,
            .downloading: 1,
            .created: 2,
            .cancelled: 3,
            .restored: 4,
            .completed: 5,
        ]

        return precedence[lhs.status, default: Int.max] < precedence[rhs.status, default: Int.max]
    }
}

enum TaskStatus {
    case created
    case cancelled
    case failed
    case completed
    case uploading
    case processing
    case downloading
    case restored
}

extension TaskStatus {
    /// In status where considered is finished
    func isFinished() -> Bool {
        return self == .cancelled || self == .completed || self == .restored
    }
}
