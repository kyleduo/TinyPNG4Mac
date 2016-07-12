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
	private var tasks = [TPTaskInfo]()
	
	private init() {}
	
	func add(task: TPTaskInfo) {
		self.tasks.append(task)
	}
	
	func add(tasks: [TPTaskInfo]) {
		self.tasks = self.tasks + tasks
	}
	
	func get(index: Int) -> TPTaskInfo? {
		if index >= 0 && index < tasks.count {
			return tasks[index]
		}
		return nil
	}
	
	func remove(task: TPTaskInfo) -> TPTaskInfo? {
		let index = self.tasks.indexOf({$0.uuid == task.uuid})
		if let i = index {
			return self.tasks.removeAtIndex(i)
		}
		return nil;
	}
	
	func indexOf(task: TPTaskInfo) -> Int {
		if let i = self.tasks.indexOf({$0.uuid == task.uuid}) {
			return i
		}
		return -1
	}
	
	func count() -> Int {
		return tasks.count
	}
	
	func moveToLast(task: TPTaskInfo) {
		let index = indexOf(task);
		let t = tasks.removeAtIndex(index)
		self.tasks.append(t)
		print(self.tasks)
	}
	
	func sort() {
		tasks.sortInPlace { (first, second) -> Bool in
			let fi = indexOf(first)
			let si = indexOf(second)
			if first.status == .ERROR && second.status != .ERROR {
				return true
			} else if first.status != .FINISH && second.status == .FINISH {
				return true
			}
			return fi < si
		}
	}
}