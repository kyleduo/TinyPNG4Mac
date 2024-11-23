//
//  ImageTask.swift
//  TinePNG4Mac
//
//  Created by 张铎 on 2024/11/17.
//
import Foundation

/// 图片压缩任务
class TinyTask {
    var uuid: String
    var originUrl: URL
    var backupUrl: URL?
    var downloadUrl: URL?
    var status: TaskStatus
    /// in byte
    var originSize: UInt64?
    /// 压缩后的最终体积
    /// in byte
    var finalSize: UInt64?
    var errorMessage: String?
    
    init(uuid: String, originUrl: URL, backupUrl: URL?, downloadUrl: URL?, status: TaskStatus, originSize: UInt64?, finalSize: UInt64?) {
        self.uuid = uuid
        self.originUrl = originUrl
        self.backupUrl = backupUrl
        self.downloadUrl = downloadUrl
        self.status = status
        self.originSize = originSize
        self.finalSize = finalSize
        self.errorMessage = nil
    }
    
    init(originUrl: URL) {
        self.uuid = UUID().uuidString
        self.originUrl = originUrl
        self.backupUrl = nil
        self.downloadUrl = nil
        self.status = .created
        self.originSize = 0
        self.finalSize = 0
        self.errorMessage = nil
    }
    
    func setError(message: String) {
        self.status = .error
        self.errorMessage = message
    }
}

enum TaskStatus {
    case created
    case cancelled
    case error
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
        case .error:
            "Error"
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
