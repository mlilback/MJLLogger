//
//  LogHandler.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation
import Dispatch

/// Base protocol for a destination of LogEntries
public protocol MJLLogHandler {
	/// used to format log entries
	var formatter: LogFormatter { get }
	/// append the log entry to the appropriate destination
	func append(entry: LogEntry)
	/// offers equality comparison without making generic
	func equals(_ rhs: MJLLogHandler) -> Bool
	/// some handlers might want to log every message. This enables that.
	var logEverything: Bool { get }
}

extension MJLLogHandler {
	public var logEverything: Bool { return false }
}

/// LogHandler that appends log entries to a mutable attributed string (such as a NSTextStorage instance)
public final class AttributedStringLogHandler: MJLLogHandler {

	public internal(set) var formatter: LogFormatter
	public let logEverything: Bool
	public var outputString: NSMutableAttributedString
	public var hashValue: Int { return ObjectIdentifier(self).hashValue }
	
	public init(formatter: LogFormatter, output: NSMutableAttributedString, logEverything: Bool = false) {
		self.formatter = formatter
		self.outputString = output
		self.logEverything = logEverything
	}
	
	public func append(entry: LogEntry) {
		guard let attrstr = formatter.formatWithAttributes(entry: entry), attrstr.length > 0 else { return }
		outputString.append(attrstr)
		outputString.append(NSAttributedString(string: "\n"))
	}

	public func equals(_ rhs: MJLLogHandler) -> Bool {
		guard let other = rhs as? AttributedStringLogHandler else { return false }
		return self.hashValue == other.hashValue
	}
}

/// appends log entries to any stream such as stdout or a strean used for print calls
public final class TextStreamHandler: MJLLogHandler {
	var config: LogConfiguration
	var stream: TextOutputStream
	public var formatter: LogFormatter
	
	public init(stream: TextOutputStream, config: LogConfiguration, formatter: LogFormatter? = nil) {
		self.config = config
		self.stream = stream
		self.formatter = formatter ?? TokenizedLogFormatter(config: config)
	}

	public func append(entry: LogEntry) {
		guard let str = formatter.format(entry: entry), str.count > 0
			else { return }
		stream.write(str + "\n")
	}
	
	public func equals(_ rhs: MJLLogHandler) -> Bool {
		guard let other = rhs as? TextStreamHandler else { return false }
		return ObjectIdentifier(self) == ObjectIdentifier(other)
	}
}


/// appends log entries to STDERR
public final class StdErrHandler: FileHandleLogHandler {
	public init(config: LogConfiguration, formatter: LogFormatter?) {
		super.init(config: config, fileHandle: FileHandle.standardError, formatter: formatter)
	}

	public override init(config: LogConfiguration, fileHandle: FileHandle, formatter: LogFormatter?, logEverything: Bool) {
		fatalError("init with fileHandle not possible with StdErrHandler")
	}
}

/// appends log entries to a file handle on a background, serial queue
open class FileHandleLogHandler: MJLLogHandler {
	private var handle: FileHandle?
	// had a deadlock on the main thread. makes no sense since there was no recursive call to append, which is the only place this queue is used
	private let queue = DispatchQueue(label: "com.lilback.MJLLogger.fileHandleLogHandler", qos: .userInitiated, attributes: .concurrent, target: .global())
	public let formatter: LogFormatter
	public let config: LogConfiguration
	public let logEverything: Bool
	public var hashValue: Int { return ObjectIdentifier(self).hashValue }

	public init(config: LogConfiguration, fileHandle: FileHandle, formatter: LogFormatter?, logEverything: Bool = false)
	{
		self.config = config
		self.handle = fileHandle
		self.formatter = formatter ?? TokenizedLogFormatter(config: config)
		self.logEverything = logEverything
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

	public func equals(_ rhs: MJLLogHandler) -> Bool {
		guard let other = rhs as? FileHandleLogHandler else { return false }
		return self.hashValue == other.hashValue
	}
}
