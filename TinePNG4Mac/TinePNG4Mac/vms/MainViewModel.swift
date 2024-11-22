//
//  MainViewModel.swift
//  TinePNG4Mac
//
//  Created by 张铎 on 2024/11/17.
//

import SwiftUI
import UniformTypeIdentifiers

class MainViewModel: ObservableObject {
    @Published var tasks: [ImageTask] = []
    @Published var requestPermission: Bool = false
    
    func createTasks(imageURLs: [URL]) {
        Task {
            for url in imageURLs {
                let originUrl = url.path()
                if !DocumentUtils.hasReadAndWritePermission(path: originUrl) {
                    DispatchQueue.main.async {
                        self.requestPermission = true
                    }
                    break
                }
                
                if !DocumentUtils.exists(path: originUrl) {
                    let task = ImageTask(originUrl: originUrl)
                    task.setError(message: "File not exists.")
                    appendTask(task: task)
                    continue
                }
                
                let uuid = UUID().uuidString
                
                let backupUrl = DocumentUtils.getBackupPath(id: uuid)
                let backupRet = DocumentUtils.createBackup(id: uuid, sourcePath: originUrl, targetPath: backupUrl)
                if !backupRet {
                    let task = ImageTask(originUrl: originUrl)
                    task.setError(message: "Fail to create backup.")
                    appendTask(task: task)
                    continue
                }
                
                let downloadUrl = DocumentUtils.getDownloadPath(id: uuid)
                
                let task = ImageTask(originUrl: originUrl)
                task.backupUrl = backupUrl
                task.downloadUrl = downloadUrl
                task.originSize = DocumentUtils.getFileSize(path: originUrl)
              
                print("task created: \(task)")
                
                appendTask(task: task)
            }
        }
    }
    
    private func appendTask(task: ImageTask) {
        DispatchQueue.main.async {
            self.tasks.append(task)
        }
    }
}
