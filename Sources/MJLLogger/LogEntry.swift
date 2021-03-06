//
//  LogEntry.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation

/// The data associated with an entry in the log
public struct LogEntry: Codable {
	/// content type of a LogEntry
	///
	/// - entry: a normal log entry
	/// - start: designates the application being launched (or at least, logging enabled)
	public enum EntryType: String, Codable {
		case entry
		case start
	}
	
	/// the type of entry. defaults to `.entry`
	public let type: EntryType
	/// the log message. defaults to empty string. replaces newlines with spaces
	public let message: String
	/// the level of the entry. defaults to `.info`
	public private(set) var level: MJLLogLevel
	// the category of the entry, defaults to `.general`
	public let category: LogCategory
	/// the name of the function that created the entry
	public let function: String?
	/// the line number of the call to create the entry
	public let line: Int?
	/// the filename/path to the file with the call to create the entry
	public let fileName: String?
	/// the timestamp of when the entry was created
	public let date: Date
	
	/// initializes a new LogEntry. All values have default values
	public init(type: EntryType = .entry, message: String = "", level: MJLLogLevel = .info, category: LogCategory = .general, function: String? = nil, line: Int? = nil, fileName: String? = nil)
	{
		self.type = type
		self.message = message.replacingOccurrences(of: "\n", with: " ")
		self.level = level
		self.category = category
		self.function = function
		self.line = line
		self.fileName = fileName
		self.date = Date()
	}
}
