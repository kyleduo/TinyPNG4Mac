//
//  URLUtils.swift
//  TinyPNG4Mac
//
//  Created by kyleduo on 2024/11/23.
//

import Foundation

extension URL {
    /// Returns a shortened path in the format `../xxx/yyy` or `../xxx` based on the URL path components.
    /// - Returns: A shortened version of the path, following the provided rules.
    func shortPath() -> String {
        let pathComponents = self.pathComponents

        // Rule 1: Keep the last 2 path components, or just the last one if the length is too long.
        let shortComponents: [String]

        if pathComponents.count > 2 {
            let lastTwo = Array(pathComponents.suffix(2))
            let formattedPath = lastTwo.joined(separator: "/")
            // Rule 3: If the length exceeds 40 characters, return only the last path component
            if formattedPath.count > 40 {
                shortComponents = [lastTwo.last ?? ""]
            } else {
                shortComponents = lastTwo
            }
        } else {
            // If there are fewer than 2 components, return the full path
            shortComponents = pathComponents
        }

        // Format the shortened path in `../xxx/yyy` style
        return "../" + shortComponents.joined(separator: "/")
    }

    func isSameFilePath(as other: URL) -> Bool {
        // Standardize both URLs to remove trailing slashes
        let standardizedSelf = standardized.path
        let standardizedOther = other.standardized.path

        // Compare the paths ignoring any trailing slashes
        return standardizedSelf.trimmingCharacters(in: CharacterSet(charactersIn: "/")) ==
            standardizedOther.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }

    /// - Returns: path without percent  encoded
    func rawPath() -> String {
        path(percentEncoded: false)
    }

    /// Check whether the file exists
    func fileExists() -> Bool {
        FileUtils.exists(path: rawPath())
    }

    /// Make a copy of current file to `target` path
    func copyFileTo(_ target: URL, override: Bool = false) throws {
        try FileUtils.copyFile(sourcePath: rawPath(), targetPath: target.rawPath(), override: override)
    }

    func moveFileTo(_ dst: URL) throws {
        try FileUtils.moveFile(self, to: dst)
    }

    func hasPermission() -> Bool {
        FileUtils.hasReadAndWritePermission(path: rawPath())
    }

    func sizeOfFile() throws -> UInt64 {
        try FileUtils.getFileSize(path: rawPath())
    }

    func posixPermissionsOfFile() -> Int? {
        FileUtils.getFilePermission(path: rawPath())
    }

    func setPosixPermissions(_ permissions: Int) {
        do {
            try? FileUtils.setFilePermission(permissions, to: rawPath())
        }
    }

    func ensureDirectoryExists() throws {
        try FileUtils.ensureDirectoryExist(file: self)
    }
}
