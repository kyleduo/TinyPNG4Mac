//
//  KeyStore.swift
//  tinypng
//
//  Created by kyle on 16/7/1.
//  Copyright © 2016年 kyleduo. All rights reserved.
//

import Foundation

class KeyStore {
	static let KEY = "saved_api_key"
	
	static func saveKey(key: String) {
		NSUserDefaults.standardUserDefaults().setObject(key, forKey: KEY)
	}
	
	static func savedkey() -> String? {
		return NSUserDefaults.standardUserDefaults().stringForKey(KEY)
	}
}