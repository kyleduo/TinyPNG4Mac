////
//  AppConfig.swift
//  TinyPNG4Mac
//
//  Created by kyleduo on 2024/12/1.
//

import Foundation

class AppConfig {
    static let key_apiKey = "apikey"
    static let key_preserveCopyright = "preserveCopyright"
    static let key_preserveCreation = "preserveCreation"
    static let key_preserveLocation = "preserveLocation"
    static let key_concurrentTaskCount = "concurrentTaskCount"
    static let key_saveMode = "saveMode"
    static let key_outputDirectory = "outputDirectory"

    private static let key_migrated = "migrated"

    // Deprecated
    static let key_replaceMode = "replaceMode"
    // Deprecated
    private static let key_outputFilepathBookmark = "outputFilepathBookmark"

    private static let defaultOutputDirectoryName = "tinyimage_output"

    static let saveModeNameOverwrite = "Overwrite"
    static let saveModeNameSaveAs = "Save As"
    static let saveModeKeys = [
        saveModeNameOverwrite,
        saveModeNameSaveAs,
    ]

    private(set) var apiKey: String = ""
    private(set) var concurrentTaskCount: Int = 3
    private(set) var saveMode: String = saveModeNameOverwrite
    private(set) var outputDirectoryUrl: URL?
    private(set) var preserveCopyright: Bool = false
    private(set) var preserveCreation: Bool = false
    private(set) var preserveLocation: Bool = false

    private var hasMigrated = false

    init() {
        migrateDeprecatedKeys()

        update()
    }

    func isOverwriteMode() -> Bool {
        return saveMode == AppConfig.saveModeNameOverwrite
    }

    func isSaveAsMode() -> Bool {
        return saveMode == AppConfig.saveModeNameSaveAs
    }

    func update() {
        let ud = UserDefaults.standard

        let apiKey = ud.string(forKey: AppConfig.key_apiKey) ?? ""

        self.apiKey = apiKey

        let concurrentTaskCountValue = ud.integer(forKey: AppConfig.key_concurrentTaskCount)
        concurrentTaskCount = concurrentTaskCountValue > 0 ? concurrentTaskCountValue : 3

        preserveCopyright = ud.bool(forKey: AppConfig.key_preserveCopyright)
        preserveCreation = ud.bool(forKey: AppConfig.key_preserveCreation)
        preserveLocation = ud.bool(forKey: AppConfig.key_preserveLocation)

        if let saveMode = ud.string(forKey: AppConfig.key_saveMode) {
            self.saveMode = saveMode
        } else {
            saveMode = AppConfig.saveModeNameOverwrite
            ud.set(AppConfig.saveModeNameOverwrite, forKey: AppConfig.key_saveMode)
        }

        if let outputDirectoryUrl = ud.string(forKey: AppConfig.key_outputDirectory) {
            self.outputDirectoryUrl = URL(filePath: outputDirectoryUrl)
        } else {
            outputDirectoryUrl = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first?.appendingPathComponent(AppConfig.defaultOutputDirectoryName, isDirectory: true)
        }
    }

    private func migrateDeprecatedKeys() {
        if hasMigrated {
            return
        }

        let ud = UserDefaults.standard

        hasMigrated = ud.bool(forKey: AppConfig.key_migrated)
        if hasMigrated {
            return
        }

        // save migrated
        ud.set(true, forKey: AppConfig.key_migrated)

        // migrate key_replaceMode to key_saveMode
        if ud.string(forKey: AppConfig.key_saveMode) == nil {
            if ud.bool(forKey: AppConfig.key_replaceMode) {
                saveMode = AppConfig.saveModeNameOverwrite
            } else {
                saveMode = AppConfig.saveModeNameSaveAs
            }
            ud.set(saveMode, forKey: AppConfig.key_saveMode)
        }
        ud.removeObject(forKey: AppConfig.key_replaceMode)

        if ud.string(forKey: AppConfig.key_outputDirectory) == nil {
            let outputFolderBookmark = ud.data(forKey: AppConfig.key_outputFilepathBookmark)
            if let outputFolderBookmark {
                var isStale = false
                do {
                    let testURL = try URL(resolvingBookmarkData: outputFolderBookmark, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
                    outputDirectoryUrl = testURL
                    if isStale {
                        print("Bookmark is stale, consider updating it.")
                    }

                    if testURL.startAccessingSecurityScopedResource() {
                        print("Restored access to folder: \(testURL.path)")
                    }
                } catch {
                    print("Failed to restore folder access: \(error)")
                }
            }

            if let outputDirectoryUrl = outputDirectoryUrl {
                ud.set(outputDirectoryUrl, forKey: AppConfig.key_outputDirectory)
            }
        }
        ud.removeObject(forKey: AppConfig.key_outputFilepathBookmark)
    }

    func saveBookmark(for folderURL: URL) throws {
        let bookmark = try folderURL.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
        UserDefaults.standard.set(bookmark, forKey: AppConfig.key_outputFilepathBookmark)
    }

    func clearOutputFolder() {
        UserDefaults.standard.removeObject(forKey: AppConfig.key_outputFilepathBookmark)
        if let outputFolderUrl = outputDirectoryUrl {
            outputFolderUrl.stopAccessingSecurityScopedResource()
            outputDirectoryUrl = nil
        }
    }

    func needPreserveMetadata() -> Bool {
        return preserveCopyright || preserveCreation || preserveLocation
    }
}
