//
//  DocumentUtils.swift
//  TinePNG4Mac
//
//  Created by 张铎 on 2024/11/16.
//

import UniformTypeIdentifiers

struct DocumentUtils {
    private static var backupPath: URL? = nil
    private static var downloadPath: URL? = nil

    static func initPaths() {
        let fileManager = FileManager.default

        let appDocDirectory = getCachesDirectory()
        let appCacheDirectory = getCachesDirectory()
        
        self.backupPath = appDocDirectory.appendingPathComponent("backup")
        self.downloadPath = appCacheDirectory.appendingPathComponent("download")

        // Define the paths you want to ensure exist
        let pathsToCheck = [
            self.backupPath!,
            self.downloadPath!
        ]

        // Iterate through the paths and create directories if they do not exist
        for path in pathsToCheck {
            do {
                if !fileManager.fileExists(atPath: path.path) {
                    // Create the directory if it does not exist
                    try fileManager.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
                    print("Directory created: \(path.path)")
                } else {
                    print("Directory already exists: \(path.path)")
                }
            } catch {
                print("Error creating directory at \(path.path): \(error.localizedDescription)")
            }
        }
    }

    static func getBackupPath(id: String) -> String {
        return backupPath!.appendingPathComponent(id).path()
    }

    static func getDownloadPath(id: String) -> String {
        return downloadPath!.appendingPathComponent(id).path()
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

    // Function to get the Documents Directory
    private static func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    // Function to get the Caches Directory
    private static func getCachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
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
                print("File copied successfully to \(targetPath)")
                return true
            } else {
                print("Source file does not exist at path: \(sourcePath)")
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
