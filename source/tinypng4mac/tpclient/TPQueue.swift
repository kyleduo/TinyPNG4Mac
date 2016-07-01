//
//  TPQueue.swift
//  tinypng
//
//  Created by kyle on 16/6/30.
//  Copyright © 2016年 kyleduo. All rights reserved.
//

import Foundation

class TPQueue {
	var queue: [TPTaskInfo]
	
	init() {
		queue = [TPTaskInfo]()
	}
	
	func enqueue(object: TPTaskInfo) {
		queue.append(object)
	}
	
	func dequeue() -> TPTaskInfo? {
		if !isEmpty() {
			return queue.removeFirst()
		} else {
			return nil
		}
	}
	
	func isEmpty() -> Bool {
		return queue.isEmpty
	}
	
	func peek() -> TPTaskInfo? {
		return queue.first
	}
	
	func size() -> Int {
		return queue.count
	}
}