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
	
	static func saveKey(key: String) {
		NSUserDefaults.standardUserDefaults().setObject(key, forKey: KEY_API)
	}
	
	static func savedkey() -> String? {
		return NSUserDefaults.standardUserDefaults().stringForKey(KEY_API)
	}
	
	static func savePath(path: String) {
		NSUserDefaults.standardUserDefaults().setObject(path, forKey: KEY_OUTPUT_FILE)
	}
	
	static func savedPath() -> String? {
		var path = NSUserDefaults.standardUserDefaults().stringForKey(KEY_OUTPUT_FILE)
		if path == nil || path == "" {
			path = IOHeler.getDefaultOutputPath().path!
			TPConfig.savePath(path!)
		}
		return path
	}
	
	static func removeKey() {
		NSUserDefaults.standardUserDefaults().removeObjectForKey(KEY_API)
	}
}