//
//  DocumentUtils.swift
//  TinePNG4Mac
//
//  Created by kyleduo on 2024/11/16.
//

import UniformTypeIdentifiers

struct DocumentUtils {
    private static let fileManager = FileManager.default

    private static let sessionId = UUID().uuidString
    private static let cacheRootDir = getCachesDirectory()
    private static let sessionRootDir = getCachesDirectory(sessionId)

    private static var backupDir: URL = sessionRootDir.appendingPathComponent("backup")
    private static var downloadDir: URL = sessionRootDir.appendingPathComponent("download")

    static func initPaths() {
        let fileManager = FileManager.default

        Task {
            do {
                let otherSessionsDir = try fileManager.contentsOfDirectory(atPath: cacheRootDir.path(percentEncoded: false))
                for dir in otherSessionsDir {
                    let dirUrl = cacheRootDir.appendingPathComponent(dir)
                    if dirUrl.isSameFilePath(as: sessionRootDir) {
                        print("same")
                        continue
                    }
                    let dirPath = dirUrl.path(percentEncoded: false)
                    try fileManager.removeItem(atPath: dirPath)
                    print("Delete \(dirPath)")
                }
            } catch {
                print("Error delete other session caches")
            }
        }

        let pathsToCheck = [
            sessionRootDir,
            backupDir,
            downloadDir,
        ]

        for path in pathsToCheck {
            do {
                if !fileManager.fileExists(atPath: path.path) {
                    // Create the directory if it does not exist
                    try fileManager.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
                }
            } catch {
                print("Error creating directory at \(path.path): \(error.localizedDescription)")
            }
        }
    }

    static func getBackupUrl(id: String) -> URL {
        return backupDir.appendingPathComponent(id)
    }

    static func getDownloadUrl(id: String) -> URL {
        return downloadDir.appendingPathComponent(id)
    }

    // Function to get the Application Support Directory
    private static func getAppSupportDirectory() -> URL? {
        let fileManager = FileManager.default
        do {
            let appSupportDir = try fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            return appSupportDir
        } catch {
            print("Error getting Application Support Directory: \(error.localizedDescription)")
            return nil
        }
    }

    private static func getCachesDirectory(_ key: String? = nil) -> URL {
        let cacheRootDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        if key != nil {
            return cacheRootDir.appendingPathComponent(key!)
        } else {
            return cacheRootDir
        }
    }

    /// 创建备份文件
    /// 返回备份文件路径
    static func createBackup(id: String, sourcePath: String, targetPath: String) -> Bool {
        let fileManager = FileManager.default

        do {
            // Check if the source file exists
            if fileManager.fileExists(atPath: sourcePath) {
                // Attempt to copy the file to the target path
                try fileManager.copyItem(atPath: sourcePath, toPath: targetPath)
                return true
            } else {
                print("Create Backup, Source file does not exist at path: \(sourcePath)")
                return false
            }
        } catch {
            // Handle any error during copying
            print("Error copying file: \(error.localizedDescription)")
            return false
        }
    }

    static func exists(path: String) -> Bool {
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: path)
    }

    static func hasReadAndWritePermission(path: String) -> Bool {
        let fileManager = FileManager.default
        return fileManager.isReadableFile(atPath: path) && fileManager.isWritableFile(atPath: path)
    }

    static func getFileSize(path: String) -> UInt64? {
        let fileManager = FileManager.default

        do {
            // Get the attributes of the file at the given path
            let attributes = try fileManager.attributesOfItem(atPath: path)

            // Retrieve the file size from the attributes dictionary
            if let fileSize = attributes[.size] as? NSNumber {
                return fileSize.uint64Value
            } else {
                print("File size could not be retrieved.")
                return nil
            }
        } catch {
            // Handle any error that occurs while fetching the attributes
            print("Error retrieving file attributes: \(error.localizedDescription)")
            return nil
        }
    }

    static func getFilePermission(path: String) -> Int? {
        let fileManager = FileManager.default

        do {
            // Get the attributes of the file at the given path
            let attributes = try fileManager.attributesOfItem(atPath: path)

            // Retrieve the file size from the attributes dictionary
            if let filePermission = attributes[.posixPermissions] as? NSNumber {
                return filePermission.intValue
            } else {
                print("File size could not be retrieved.")
                return nil
            }
        } catch {
            // Handle any error that occurs while fetching the attributes
            print("Error retrieving file attributes: \(error.localizedDescription)")
            return nil
        }
    }

    static func setFilePermission(_ permission: Int, to filePath: String) {
        do {
            try fileManager.setAttributes([FileAttributeKey.posixPermissions: permission], ofItemAtPath: filePath)
        } catch {
            print("error set file permission")
        }
    }

    static func moveFile(_ src: URL, to dst: URL) {
        do {
            if fileManager.fileExists(atPath: dst.path(percentEncoded: false)) {
                print("The file already exists at the target path.")

                // You can either overwrite or rename the destination file:

                // Option 1: Overwrite the file
                try fileManager.removeItem(at: dst) // Remove the existing file
                try fileManager.moveItem(at: src, to: dst)
                print("File overwritten.")
            } else {
                // The file doesn't exist, so you can safely copy it
                try fileManager.copyItem(at: src, to: dst)
                print("File copied successfully.")
            }
        } catch {
            print("Error copying file: \(error.localizedDescription)")
        }
    }

    /// 递归查找图片文件的 URL
    static func findImageFiles(urls: [URL]) -> [URL] {
        var imageFiles = Set<URL>()
        let validExtensions = ["jpeg", "jpg", "png", "webp"]

        for url in urls {
            if url.hasDirectoryPath {
                // Recursively fetch files in folder
                if let folderFiles = fetchFilesRecursively(from: url) {
                    for fileURL in folderFiles {
                        if isValidImageFile(fileURL, withExtensions: validExtensions) {
                            imageFiles.insert(fileURL)
                        }
                    }
                }
            } else if isValidImageFile(url, withExtensions: validExtensions) {
                // Directly add the valid file
                imageFiles.insert(url)
            }
        }

        return Array(imageFiles)
    }

    private static func fetchFilesRecursively(from folderURL: URL) -> [URL]? {
        let fileManager = FileManager.default
        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles, .skipsSubdirectoryDescendants]

        if let enumerator = fileManager.enumerator(at: folderURL, includingPropertiesForKeys: nil, options: options) {
            return enumerator.compactMap { $0 as? URL }
        }

        return nil
    }

    private static func isValidImageFile(_ url: URL, withExtensions validExtensions: [String]) -> Bool {
        let fileExtension = url.pathExtension.lowercased()
        return validExtensions.contains(fileExtension)
    }
}
