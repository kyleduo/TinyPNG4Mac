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
    static let key_usedQuotaCache = "usedQuotaCache"
    static let key_convertingConfig = "convertingConfig"
    
    private static let key_migrated = "migrated"

    // Deprecated
    static let key_replaceMode = "replaceMode"
    // Deprecated
    private static let key_outputFilepathBookmark = "outputFilepathBookmark"

    private static let defaultOutputDirectoryName = "tinyimage_output"

    static let saveModeNameOverwrite = "Overwrite"
    static let saveModeNameSaveAs = "Save As"
    private static let defaultSaveModeName = saveModeNameSaveAs
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
    /// Save the latest quota remaining for each key
    /// key: prefix of 8 length of api_key
    /// value: remaining quota from latest response
    private(set) var usedQuotaCache: [String:Int] = [:]
    /// config of format converting
    /// list of target format, nil for don't convert, empty list for auto converting
    private(set) var convertingConfig: [String]? = nil

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
            saveMode = AppConfig.defaultSaveModeName
            ud.set(AppConfig.defaultSaveModeName, forKey: AppConfig.key_saveMode)
        }

        if let outputDirectoryUrl = ud.string(forKey: AppConfig.key_outputDirectory) {
            self.outputDirectoryUrl = URL(filePath: outputDirectoryUrl)
        } else {
            outputDirectoryUrl = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first?.appendingPathComponent(AppConfig.defaultOutputDirectoryName, isDirectory: true)
        }

        if let usedQuotaCache = ud.dictionary(forKey: AppConfig.key_usedQuotaCache) {
            usedQuotaCache.forEach { (key: String, value: Any) in
                if let quota = value as? Int {
                    self.usedQuotaCache[key] = quota
                }
            }
        }

        if let convertConfig = ud.array(forKey: AppConfig.key_convertingConfig) {
            var configs: [String] = []
            convertConfig.forEach { e in
                if let format = e as? String {
                    configs.append(format)
                }
            }
            // There's error data in ud, replace it
            if configs.count != convertConfig.count {
                ud.set(configs, forKey: AppConfig.key_convertingConfig)
            }
            if configs.isEmpty {
                self.convertingConfig = []
            }
        } else {
            self.convertingConfig = nil
        }
    }

    func currentUsedQuota() -> Int? {
        if apiKey.isEmpty || apiKey.count < 8 {
            return nil
        }
        let key = String(apiKey.prefix(8))
        return self.usedQuotaCache[key]
    }

    func saveUsedQuota(_ quota: Int) {
        if apiKey.isEmpty || apiKey.count < 8 {
            return
        }
        let key = String(apiKey.prefix(8))
        self.usedQuotaCache[key] = quota
        UserDefaults.standard.set(self.usedQuotaCache, forKey: AppConfig.key_usedQuotaCache)
    }

    func saveConvertConfig(_ config: [String]?) {
        self.convertingConfig = config
        if self.convertingConfig == nil {
            UserDefaults.standard.removeObject(forKey: AppConfig.key_convertingConfig)
        } else {
            UserDefaults.standard.set(self.convertingConfig, forKey: AppConfig.key_convertingConfig)
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
