//
//  Formator.swift
//  tinypng
//
//  Created by kyle on 16/7/1.
//  Copyright © 2016年 kyleduo. All rights reserved.
//

import Foundation

class Formator {
	static func formatSize(_ byte: Double) -> String {
		if byte < 1024 {
			return String.init(format: "%.2fB", byte)
		} else if byte < 1024 * 1024 {
			return String.init(format: "%.2fK", byte / 1024)
		} else if byte < 1024 * 1024 * 1024 {
			return String.init(format: "%.2fM", byte / 1024 / 1024)
		} else {
			return "Too Large"
		}
	}
	
	static func formatRate(_ rate: Double) -> String {
		return String.init(format: "%.1f%%", rate * 100)
	}
}
