//
//  LogConfiguration.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation

/// This protocol defines what information a Logger needs to work. Because this module can be used in embedded frameworks, this can't be accomplished by a class. It can't be implemented by a struct either, since you can't (easily) keep a reference to a struct.
/// This is solved by using a protocol. A DefaultLogConfiguration struct allows you to quickly get up and running with the system.
/// If you desire the configuration to be configurable at runtime (e.g. dynamically adjusting the log level), create your own class that implements this protocol.
public protocol LogConfiguration {
	var dateFormatter: DateFormatterProtocol { get }

	func loggingEnabled(level: LogLevel, category: LogCategory) -> Bool
}

public struct DefaultLogConfiguration: LogConfiguration {
	public let dateFormatter: DateFormatterProtocol
	public let globalLevel: LogLevel
	
	public init(level: LogLevel = .warn, dateFormatter: DateFormatterProtocol = ISO8601DateFormatter()) {
		self.dateFormatter = dateFormatter
		self.globalLevel = level
	}
	
	public func loggingEnabled(level: LogLevel, category: LogCategory) -> Bool {
		return level.rawValue <= globalLevel.rawValue
	}
}
