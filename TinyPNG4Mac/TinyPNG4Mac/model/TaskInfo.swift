//
//  ImageTask.swift
//  TinyPNG4Mac
//
//  Created by kyleduo on 2024/11/17.
//
import Foundation
import SwiftUI

/// 图片压缩任务
class TaskInfo: Identifiable {
    var id: String
    var originUrl: URL
    var filePermission: Int?
    var previewImage: NSImage?
    var backupUrl: URL?
    var downloadUrl: URL?
    var status: TaskStatus
    /// in byte
    var originSize: UInt64?
    /// 压缩后的最终体积
    /// in byte
    var finalSize: UInt64?
    var errorCode: Int = 0
    var errorMessage: String?
    /// upload / download progress
    var progress: Double = 0

    init(
        id: String,
        originUrl: URL,
        status: TaskStatus,
        filePermission: Int? = nil,
        previewImage: NSImage? = nil,
        backupUrl: URL? = nil,
        downloadUrl: URL? = nil,
        originSize: UInt64? = nil,
        finalSize: UInt64? = nil,
        errorCode: Int = 0,
        errorMessage: String? = nil,
        progress: Double = 0
    ) {
        self.id = id
        self.originUrl = originUrl
        self.status = status
        self.filePermission = filePermission
        self.previewImage = previewImage
        self.backupUrl = backupUrl
        self.downloadUrl = downloadUrl
        self.originSize = originSize
        self.finalSize = finalSize
        self.errorCode = errorCode
        self.errorMessage = errorMessage
        self.progress = progress
    }

    init(originUrl: URL, backupUrl: URL, downloadUrl: URL, originSize: UInt64, filePermission: Int, previewImage: NSImage) {
        id = UUID().uuidString
        status = .created
        self.previewImage = previewImage
        self.originUrl = originUrl
        self.backupUrl = backupUrl
        self.downloadUrl = downloadUrl
        self.originSize = originSize
        self.filePermission = filePermission
    }

    init(originUrl: URL) {
        id = UUID().uuidString
        self.originUrl = originUrl
        filePermission = nil
        backupUrl = nil
        downloadUrl = nil
        status = .created
        originSize = 0
        finalSize = 0
        errorMessage = nil
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
            lhs.errorCode == rhs.errorCode &&
            lhs.errorMessage == rhs.errorMessage
    }
}

extension TaskInfo {
    
    func statusText() -> String {
        if (status == .uploading || status == .downloading) && progress > 0 {
            status.displayText() + " (\(progress * 100) %)"
        } else {
            status.displayText()
        }
    }
    
    func updateError(message: String) {
        status = .failed
        errorMessage = message
    }
    
    func updateStatus(_ newStatus: TaskStatus, progress: Double? = nil) {
        self.status = newStatus
        if let progress {
            self.progress = progress
        }
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
            .completed: 4,
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
}

extension TaskStatus {
    func displayText() -> String {
        switch self {
        case .created:
            "Pending"
        case .cancelled:
            "Cancelled"
        case .failed:
            "Failed"
        case .completed:
            "Completed"
        case .uploading:
            "Uploading"
        case .processing:
            "Processing"
        case .downloading:
            "Downloading"
        }
    }
}
