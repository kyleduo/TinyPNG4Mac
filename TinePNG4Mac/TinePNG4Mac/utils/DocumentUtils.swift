//
//  DocumentUtils.swift
//  TinePNG4Mac
//
//  Created by 张铎 on 2024/11/16.
//

import UniformTypeIdentifiers

struct DocumentUtils {
    
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
