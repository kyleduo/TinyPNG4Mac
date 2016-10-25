//
//  TPStore.swift
//  tinypng
//
//  Created by kyle on 16/6/30.
//  Copyright © 2016年 kyleduo. All rights reserved.
//

import Foundation

class TPStore {
	static let sharedStore = TPStore()
	fileprivate var tasks = [TPTaskInfo]()
	
	fileprivate init() {}
	
	func add(_ task: TPTaskInfo) {
		self.tasks.append(task)
	}
	
	func add(_ tasks: [TPTaskInfo]) {
		self.tasks = self.tasks + tasks
	}
	
	func get(_ index: Int) -> TPTaskInfo? {
		if index >= 0 && index < tasks.count {
			return tasks[index]
		}
		return nil
	}
	
	func remove(_ task: TPTaskInfo) -> TPTaskInfo? {
		let index = self.tasks.index(where: {$0.uuid == task.uuid})
		if let i = index {
			return self.tasks.remove(at: i)
		}
		return nil;
	}
	
	func indexOf(_ task: TPTaskInfo) -> Int {
		if let i = self.tasks.index(where: {$0.uuid == task.uuid}) {
			return i
		}
		return -1
	}
	
	func count() -> Int {
		return tasks.count
	}
	
	func moveToLast(_ task: TPTaskInfo) {
		let index = indexOf(task);
		let t = tasks.remove(at: index)
		self.tasks.append(t)
		debugPrint(self.tasks)
	}
	
	func sort() {
		tasks.sort { (first, second) -> Bool in
			let fi = indexOf(first)
			let si = indexOf(second)
			if first.status == .error && second.status != .error {
				return true
			} else if first.status != .finish && second.status == .finish {
				return true
			}
			return fi < si
		}
	}
}
