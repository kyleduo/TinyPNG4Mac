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
    static let key_replaceMode = "replaceMode"
    
    private static let key_outputFilepathBookmark = "outputFilepathBookmark"

    private(set) var apiKey: String = ""
    private(set) var concurrentTaskCount: Int = 3
    private(set) var isReplaceModeEnabled: Bool = false
    private(set) var outputFolderUrl: URL?

    init() {
        update()
    }

    func update() {
        let ud = UserDefaults.standard

        let apiKey = ud.string(forKey: AppConfig.key_apiKey) ?? ""

        self.apiKey = apiKey

        let concurrentTaskCountValue = ud.integer(forKey: AppConfig.key_concurrentTaskCount)
        concurrentTaskCount = concurrentTaskCountValue > 0 ? concurrentTaskCountValue : 3

        isReplaceModeEnabled = ud.bool(forKey: AppConfig.key_replaceMode)

        let outputFolderBookmark = ud.data(forKey: AppConfig.key_outputFilepathBookmark)
        if let outputFolderBookmark {
            var isStale = false
            do {
                let testURL = try URL(resolvingBookmarkData: outputFolderBookmark, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
                self.outputFolderUrl = testURL
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
    }

    func saveBookmark(for folderURL: URL) throws {
        let bookmark = try folderURL.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
        UserDefaults.standard.set(bookmark, forKey: AppConfig.key_outputFilepathBookmark)
    }
    
    func clearOutputFolder() {
        if !AppContext.shared.isDebug {
            return
        }
        UserDefaults.standard.removeObject(forKey: AppConfig.key_outputFilepathBookmark)
        if let outputFolderUrl = self.outputFolderUrl {
            outputFolderUrl.stopAccessingSecurityScopedResource()
            self.outputFolderUrl = nil
        }
    }
}
