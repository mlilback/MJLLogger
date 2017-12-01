//
//  LogEntry.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation

/// The data associated with an entry in the log
public struct LogEntry {
	let message: String
	private(set) var level: LogLevel
	let category: LogCategory
	let function: String
	let line: Int
	let fileName: String
	let date = Date()
	
//	mutating internal func changeLevel(_ newLevel: LogLevel) {
//		self.level = newLevel
//	}
}

