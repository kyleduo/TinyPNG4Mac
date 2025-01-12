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
    private static let sessionRootDir = cacheRootDir.appendingPathComponent(sessionId, isDirectory: true)

    private static var backupDir: URL = sessionRootDir.appendingPathComponent("backup", isDirectory: true)
    private static var downloadDir: URL = sessionRootDir.appendingPathComponent("download", isDirectory: true)

    static func initPaths() {
        let pathsToCheck = [
            cacheRootDir,
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

        if !AppUtils.isPreviewMode() {
            Task {
                cleanSandboxCacheDir()
                cleanPreviousSessions()
            }
        }
        
        DebugViewModel.shared.debugMessages.append("initPaths complete")
    }

    private static func cleanSandboxCacheDir() {
        guard let identifier = Bundle.main.bundleIdentifier else {
            return
        }

        let userHomeDir = FileManager.default.homeDirectoryForCurrentUser
        let sandboxRootDir = URL(filePath: userHomeDir.rawPath() + "Library/Containers/\(identifier)/")

        if sandboxRootDir.fileExists() {
            do {
                try fileManager.removeItem(at: sandboxRootDir)
                print("Clean up sandbox dir.")
            } catch {
                print("Clean up sandbox dir error. \(error)")
            }
        }
    }

    private static func cleanPreviousSessions() {
        do {
            let otherSessionsDir = try fileManager.contentsOfDirectory(atPath: cacheRootDir.path(percentEncoded: false))
            for dir in otherSessionsDir {
                let dirUrl = cacheRootDir.appendingPathComponent(dir)
                if dirUrl.isSameFilePath(as: sessionRootDir) {
                    continue
                }
                let dirPath = dirUrl.path(percentEncoded: false)
                try fileManager.removeItem(atPath: dirPath)
                print("Delete previous session folder: \(dirPath)")
            }
        } catch {
            print("Error delete other session caches: \(error)")
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

    private static func getCachesDirectory() -> URL {
//        // If disable Sandbox mode, "FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)" will return the global root cache dir: ~/Library/Caches
        let userCacheRootDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let identifier = Bundle.main.bundleIdentifier ?? "com.kyleduo.app.TinyPNG4Mac"
        let cacheRootDir = userCacheRootDir.appendingPathComponent(identifier).appendingPathComponent("Caches")
        return cacheRootDir
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
    static func findImageFiles(urls: [URL]) -> [URL: URL] {
        var imageFiles: [URL: URL] = [:]
        findImageFiles(urls: urls, originUrl: nil, result: &imageFiles)
        return imageFiles
    }

    private static func findImageFiles(urls: [URL], originUrl: URL?, result: inout [URL: URL]) {
        let validExtensions = ["jpeg", "jpg", "png", "webp"]

        for url in urls {
            if url.hasDirectoryPath {
                if let folderFiles = listAllFiles(from: url) {
                    findImageFiles(urls: folderFiles, originUrl: originUrl ?? url, result: &result)
                }
            } else if isValidImageFile(url, withExtensions: validExtensions) {
                if !result.contains(where: { key, _ in
                    key.isSameFilePath(as: url)
                }) {
                    result[url] = originUrl ?? url
                }
            }
        }
    }

    private static func listAllFiles(from folderURL: URL) -> [URL]? {
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

    static func getRelocatedRelativePath(of file: URL, fromDir: URL, toDir: URL) -> URL? {
        // the file is input as a single file, return
        if file.isSameFilePath(as: fromDir) {
            return nil
        }
        guard file.path.hasPrefix(fromDir.path) else {
            return nil
        }
        let relativePath = file.rawPath().replacingOccurrences(of: fromDir.path, with: "")
        let newFileURL = toDir
            .appendingPathComponent(fromDir.lastPathComponent)
            .appendingPathComponent(relativePath)
        return newFileURL
    }

    static func ensureDirectoryExist(file: URL) throws {
        if file.hasDirectoryPath {
            try fileManager.createDirectory(at: file, withIntermediateDirectories: true)
        } else {
            try fileManager.createDirectory(at: file.deletingLastPathComponent(), withIntermediateDirectories: true)
        }
    }
}
