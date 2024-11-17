//
//  ImageTask.swift
//  TinePNG4Mac
//
//  Created by 张铎 on 2024/11/17.
//
import Foundation

/// 图片压缩任务
class ImageTask {
    var uuid: String
    var originUrl: String
    var backupUrl: String?
    var downloadUrl: String?
    var status: TaskStatus
    /// in byte
    var originSize: UInt64?
    /// 压缩后的最终体积
    /// in byte
    var finalSize: UInt64?
    var errorMessage: String?
    
    init(uuid: String, originUrl: String, backupUrl: String?, downloadUrl: String?, status: TaskStatus, originSize: UInt64?, finalSize: UInt64?) {
        self.uuid = uuid
        self.originUrl = originUrl
        self.backupUrl = backupUrl
        self.downloadUrl = downloadUrl
        self.status = status
        self.originSize = originSize
        self.finalSize = finalSize
        self.errorMessage = nil
    }
    
    init(originUrl: String) {
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
    case downloading
}
