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
    static let key_outputFilepath = "outputFilepath"

    private(set) var apiKey: String = ""

    init() {
        update()
    }

    func update() {
        let ud = UserDefaults.standard

        let apiKey = ud.string(forKey: "apikey") ?? ""

        self.apiKey = apiKey
    }
}
