//
//  DocumentUtils.swift
//  TinyPNG4Mac
//
//  Created by kyleduo on 2024/11/16.
//

import UniformTypeIdentifiers

struct FileUtils {
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

    static func copyFile(sourcePath: String, targetPath: String, override: Bool = false) throws {
        if fileManager.fileExists(atPath: sourcePath) {
            if fileManager.fileExists(atPath: targetPath) {
                if override {
                    try fileManager.removeItem(atPath: targetPath)
                } else {
                    throw FileError.dstAlreadyExists
                }
            }
            try fileManager.copyItem(atPath: sourcePath, toPath: targetPath)
        } else {
            throw FileError.notExists
        }
    }

    static func exists(path: String) -> Bool {
        return fileManager.fileExists(atPath: path)
    }

    static func hasReadAndWritePermission(path: String) -> Bool {
        return fileManager.isReadableFile(atPath: path) && fileManager.isWritableFile(atPath: path)
    }

    static func getFileSize(path: String) throws -> UInt64 {
        let attributes = try fileManager.attributesOfItem(atPath: path)
        if let fileSize = attributes[.size] as? NSNumber {
            return fileSize.uint64Value
        } else {
            return 0
        }
    }

    static func getFilePermission(path: String) -> Int? {
        guard let attributes = try? fileManager.attributesOfItem(atPath: path) else {
            return nil
        }
        if let filePermission = attributes[.posixPermissions] as? NSNumber {
            return filePermission.intValue
        } else {
            return nil
        }
    }

    static func setFilePermission(_ permission: Int, to filePath: String) throws {
        try fileManager.setAttributes([FileAttributeKey.posixPermissions: permission], ofItemAtPath: filePath)
    }

    static func moveFile(_ src: URL, to dst: URL) throws {
        if fileManager.fileExists(atPath: dst.path(percentEncoded: false)) {
            try fileManager.removeItem(at: dst) // Remove the existing file
            try fileManager.moveItem(at: src, to: dst)
        } else {
            try fileManager.moveItem(at: src, to: dst)
        }
    }

    /// Find all the valid image files recursively
    static func findImageFiles(urls: [URL]) -> [URL] {
        var imageFiles: [URL] = []
        let validExtensions = ["jpeg", "jpg", "png", "webp"]

        for url in urls {
            if url.hasDirectoryPath {
                if let folderFiles = fetchFilesRecursively(from: url) {
                    for fileURL in folderFiles {
                        if isValidImageFile(fileURL, withExtensions: validExtensions) {
                            if imageFiles.firstIndex(where: { item in item.isSameFilePath(as: fileURL) }) == nil {
                                imageFiles.append(fileURL)
                            }
                        }
                    }
                }
            } else if isValidImageFile(url, withExtensions: validExtensions) {
                if imageFiles.firstIndex(where: { item in item.isSameFilePath(as: url) }) == nil {
                    imageFiles.append(url)
                }
            }
        }

        return imageFiles
    }

    private static func fetchFilesRecursively(from folderURL: URL) -> [URL]? {
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
