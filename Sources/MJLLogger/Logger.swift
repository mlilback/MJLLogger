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
	private var started: Bool = false
	
	public init(config: LogConfiguration = DefaultLogConfiguration())
	{
		self.configuration = config
	}
	
	public func append(handler: LogHandler) {
		handlers.append(handler)
		if started {
			handler.append(entry: LogEntry(type: .start))
		}
	}
	
	public func remove(handler: LogHandler) {
		guard let idx = handlers.index(where: { handler.equals($0) }) else { return }
		handlers.remove(at: idx)
	}
	
	/// Logs a .start LogEntry to all handlers. Any handlers added later will have a start message logged
	public func logApplicationStart() {
		assert(!started, "already started")
		started = true
		let startEntry = LogEntry(type: .start)
		handlers.forEach { $0.append(entry: startEntry)}
	}
	
	public func log(_ entry: LogEntry)
	{
		handlers.forEach { $0.append(entry: entry) }
	}
}

