//
//  LogHandler.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation

/// Base protocol for a destination of LogEntries
public protocol LogHandler {
	/// used to format log entries
	var formatter: LogFormatter { get }
	/// append the log entry to the appropriate destination
	func append(entry: LogEntry)
	/// offers equality comparison without making generic
	func equals(_ rhs: LogHandler) -> Bool
}

/// LogHandler that appends log entries to a mutable attributed string (such as a NSTextStorage instance)
public final class AttributedStringLogHandler: LogHandler {

	public internal(set) var formatter: LogFormatter
	public var outputString: NSMutableAttributedString
	public var hashValue: Int { return ObjectIdentifier(self).hashValue }
	
	public init(formatter: LogFormatter, output: NSMutableAttributedString) {
		self.formatter = formatter
		self.outputString = output
	}
	
	public func append(entry: LogEntry) {
		guard let attrstr = formatter.formatWithAttributes(entry: entry) else { return }
		outputString.append(attrstr)
		outputString.append(NSAttributedString(string: "\n"))
	}

	public func equals(_ rhs: LogHandler) -> Bool {
		guard let other = rhs as? AttributedStringLogHandler else { return false }
		return self.hashValue == other.hashValue
	}
}

/// appends log entries to STDERR
public final class StdErrHandler: FileHandleLogHandler {
	public init(config: LogConfiguration, formatter: LogFormatter?) {
		super.init(config: config, fileHandle: FileHandle.standardError, formatter: formatter)
	}

	public override init(config: LogConfiguration, fileHandle: FileHandle, formatter: LogFormatter?) {
		fatalError("init with fileHandle not possible with StdErrHandler")
	}
}

/// appends log entries to a file handle on a background, serial queue
open class FileHandleLogHandler: LogHandler {
	private var handle: FileHandle?
	private let queue = DispatchQueue(label: "com.lilback.MJLLogger.fileHandleLogHandler", qos: .userInitiated)
	public let formatter: LogFormatter
	public let config: LogConfiguration
	public var hashValue: Int { return ObjectIdentifier(self).hashValue }

	public init(config: LogConfiguration, fileHandle: FileHandle, formatter: LogFormatter?)
	{
		self.config = config
		self.handle = fileHandle
		self.formatter = formatter ?? TokenizedLogFormatter(config: config)
	}
	
	deinit {
		handle?.closeFile()
		handle = nil
	}

	public func append(entry: LogEntry) {
		queue.async { [weak self]  in
			if let str = self?.formatter.format(entry: entry),
				let estr = Optional(str + "\n"),
				let data = estr.data(using: .utf8)
			{
				self?.handle?.write(data)
			}
		}
	}

	public func equals(_ rhs: LogHandler) -> Bool {
		guard let other = rhs as? FileHandleLogHandler else { return false }
		return self.hashValue == other.hashValue
	}
}
