//
//  Logger.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation

/// The base class for a logger. Subclasses should be marked final.
open class Logger {
	let configuration: LogConfiguration
	let formatter: LogFormatter
	
	public init(config: LogConfiguration = DefaultLogConfiguration(), formatter: LogFormatter = TokenizedLogFormatter())
	{
		self.configuration = config
		self.formatter = formatter
	}
	
	open func log(_ entry: LogEntry)
	{
		fatalError("subclass must implement")
	}
}

public final class TextStreamLogger: Logger {
	
	private var stream: TextOutputStream
	
	public init(stream: TextOutputStream, config: LogConfiguration = DefaultLogConfiguration(), formatter: LogFormatter = TokenizedLogFormatter())
	{
		self.stream = stream
		super.init(config: config, formatter: formatter)
	}
	
	public override func log(_ entry: LogEntry) {
		guard let str = formatter.format(entry: entry) else { return }
		stream.write(str)
		stream.write("\n")
	}
}

/// A basic implementation that outputs the log entries to standard error
public final class StdErrLogger: Logger {
	public override func log(_ entry: LogEntry)
	{
		guard let str = formatter.format(entry: entry),
			let estr = Optional(str + "\n"),
			let data = estr.data(using: .utf8)
		else { return }
		FileHandle.standardError.write(data)
	}
	
}
