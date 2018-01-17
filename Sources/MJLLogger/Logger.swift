//
//  Logger.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation

/// The base class for a logger
public final class Logger {
	let configuration: LogConfiguration
	internal var handlers = [LogHandler]()
	
	
	public init(config: LogConfiguration = DefaultLogConfiguration())
	{
		self.configuration = config
	}
	
	public func append(handler: LogHandler) {
		handlers.append(handler)
	}
	
	public func log(_ entry: LogEntry)
	{
		handlers.forEach { $0.append(entry: entry) }
	}
}

