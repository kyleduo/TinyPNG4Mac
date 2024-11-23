//
//  MainViewModel.swift
//  TinePNG4Mac
//
//  Created by 张铎 on 2024/11/17.
//

import SwiftUI
import UniformTypeIdentifiers

class MainViewModel: ObservableObject {
    @Published var tasks: [TinyTask] = []
    @Published var requestPermission: Bool = false
    
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
                    let task = TinyTask(originUrl: originUrl)
                    task.setError(message: "File not exists, skip create task.")
                    appendTask(task: task)
                    continue
                }
                
                let uuid = UUID().uuidString
                
                let backupUrl = DocumentUtils.getBackupUrl(id: uuid)
                let backupRet = DocumentUtils.createBackup(id: uuid, sourcePath: originUrlPath, targetPath: backupUrl.path(percentEncoded: false))
                if !backupRet {
                    let task = TinyTask(originUrl: originUrl)
                    task.setError(message: "Fail to create backup, skip creat task.")
                    appendTask(task: task)
                    continue
                }
                
                let downloadUrl = DocumentUtils.getDownloadUrl(id: uuid)
                
                let task = TinyTask(originUrl: originUrl)
                task.backupUrl = backupUrl
                task.downloadUrl = downloadUrl
                task.originSize = DocumentUtils.getFileSize(path: originUrlPath)
              
                print("task created: \(task)")
                
                appendTask(task: task)
            }
        }
    }
    
    private func appendTask(task: TinyTask) {
        DispatchQueue.main.async {
            self.tasks.append(task)
        }
    }
}
