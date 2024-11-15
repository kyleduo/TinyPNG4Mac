//
//  KeyStore.swift
//  tinypng
//
//  Created by kyle on 16/7/1.
//  Copyright © 2016年 kyleduo. All rights reserved.
//

import Foundation

class TPConfig {
	static let KEY_API = "saved_api_key"
	static let KEY_OUTPUT_FILE = "output_path"
	static let KEY_REPLACE = "replace"
	
	static func saveKey(_ key: String) {
		UserDefaults.standard.set(key, forKey: KEY_API)
	}
	
	static func savedkey() -> String? {
		return UserDefaults.standard.string(forKey: KEY_API)
	}
	
	static func savePath(_ path: String) {
		UserDefaults.standard.set(path, forKey: KEY_OUTPUT_FILE)
	}
	
	static func savedPath() -> String? {
		var path = UserDefaults.standard.string(forKey: KEY_OUTPUT_FILE)
		if path == nil || path == "" {
			path = IOHeler.getDefaultOutputPath().path
			TPConfig.savePath(path!)
		}
		return path
	}
	
	static func saveReplace(_ replace: Bool) {
		UserDefaults.standard.set(replace, forKey: KEY_REPLACE);
	}
	
	static func shouldReplace() -> Bool! {
		return UserDefaults.standard.bool(forKey: KEY_REPLACE)
	}
	
	static func removeKey() {
		UserDefaults.standard.removeObject(forKey: KEY_API)
		UserDefaults.standard.removeObject(forKey: KEY_REPLACE)
	}
}
