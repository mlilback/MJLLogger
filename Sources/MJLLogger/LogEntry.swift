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
	let function: String?
	let line: Int?
	let fileName: String?
	let date = Date()
	
	public init(message: String, level: LogLevel = .info, category: LogCategory = .general, function: String? = nil, line: Int? = nil, fileName: String? = nil)
	{
		self.message = message
		self.level = level
		self.category = category
		self.function = function
		self.line = line
		self.fileName = fileName
	}
}
