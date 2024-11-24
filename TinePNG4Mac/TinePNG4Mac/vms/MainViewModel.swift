//
//  MainViewModel.swift
//  TinePNG4Mac
//
//  Created by kyleduo on 2024/11/17.
//

import SwiftUI
import UniformTypeIdentifiers

class MainViewModel: ObservableObject, TPClientCallback {
    @Published var tasks: [TaskInfo] = []
    @Published var requestPermission: Bool = false
    
    init() {
        TPClient.shared.callback = self
    }
    
    func createTasks(imageURLs: [URL]) {
        Task {
            for url in imageURLs {
                let originUrl = url
                let originUrlPath = url.path(percentEncoded: false)
                if !DocumentUtils.hasReadAndWritePermission(path: originUrlPath) {
                    DispatchQueue.main.async {
                        self.requestPermission = true
                    }
                    break
                }
                
                if !DocumentUtils.exists(path: originUrlPath) {
                    var task = TaskInfo(originUrl: originUrl)
                    task.setError(message: "File not exists, skip create task.")
                    appendTask(task: task)
                    continue
                }
                
                let uuid = UUID().uuidString
                
                let backupUrl = DocumentUtils.getBackupUrl(id: uuid)
                let backupRet = DocumentUtils.createBackup(id: uuid, sourcePath: originUrlPath, targetPath: backupUrl.path(percentEncoded: false))
                if !backupRet {
                    var task = TaskInfo(originUrl: originUrl)
                    task.setError(message: "Fail to create backup, skip creat task.")
                    appendTask(task: task)
                    continue
                }
                
                let downloadUrl = DocumentUtils.getDownloadUrl(id: uuid)
                let previewImage = loadImagePreviewUsingCGImageSource(from: originUrl, maxDimension: 200)
                
                let task = TaskInfo(
                    originUrl: originUrl,
                    backupUrl: backupUrl,
                    downloadUrl: downloadUrl,
                    originSize: DocumentUtils.getFileSize(path: originUrlPath) ?? 0,
                    filePermission: DocumentUtils.getFilePermission(path: originUrlPath) ?? 0x644,
                    previewImage: previewImage ?? NSImage(named: "photo")!
                )
//                task.backupUrl = backupUrl
//                task.downloadUrl = downloadUrl
//                task.originSize = DocumentUtils.getFileSize(path: originUrlPath)
//                task.filePermission = DocumentUtils.getFilePermission(path: originUrlPath)
//                task.previewImage = previewImage
              
                print("Task created: \(task)")
                
                appendTask(task: task)
                
                TPClient.shared.addTask(task: task)
            }
        }
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
            kCGImageSourceCreateThumbnailFromImageIfAbsent: true
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
        
        if let index = tasks.firstIndex(where: { item in item.id == task.id }) {
            tasks[index] = task
            sortTasksInPlace(&tasks)
            tasks = tasks
        }
    }
    
    func sortTasksInPlace(_ tasks: inout [TaskInfo]) {
        tasks.sort { $0 < $1 }
    }
}
