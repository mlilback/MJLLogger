//
//  LogConfiguration.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation

/// This protocol defines what information a Logger needs to work. Because this module can be used in embedded frameworks, this can't be accomplished by a class. It can't be implemented by a struct either, since you can't (easily) keep a reference to a struct.
/// This is solved by using a protocol. A DefaultLogConfiguration class allows you to quickly get up and running with the system.
/// If you desire the configuration to be configurable at runtime (e.g. dynamically adjusting the log level), create your own class that implements this protocol. An implementation of such in this library would allow other frameworks to cast to that type and possibly change configuration options
public protocol LogConfiguration: class {
	/// Checks to see if logging is enabled for a particular level and category combination
	///
	/// - Parameters:
	///   - level: the LogLevel in question
	///   - category: the category in question
	/// - Returns: true if an entry should be logged for the combination of level and category
	func loggingEnabled(level: MJLLogLevel, category: LogCategory) -> Bool

	/// Returns the custom description of logLevel, or the default description if a custom one was not specified
	///
	/// - Parameter logLevel: the logLevel
	/// - Returns: a description for the logLevel
	func description(logLevel: MJLLogLevel) -> NSAttributedString
}

extension LogConfiguration {
	public func description(logLevel: MJLLogLevel) -> NSAttributedString {
		return NSAttributedString(string: logLevel.description)
	}
}

/// a basic log configuration that has a static global log level and optional dictionary of LogLevel descriptions
public final class DefaultLogConfiguration: LogConfiguration {
	/// the static global log level
	public let globalLevel: MJLLogLevel
	private let levelDescriptions: [MJLLogLevel: NSAttributedString]?
	
	/// Creates a default configuration object
	///
	/// - Parameters:
	///   - level: the default log level
	///   - levelDescriptions: a dictionary of log levels to custom, attributed descriptions of those levels
	public init(level: MJLLogLevel = .warn, levelDescriptions: [MJLLogLevel: NSAttributedString]? = nil) {
		self.globalLevel = level
		self.levelDescriptions = levelDescriptions
	}
	
	public func loggingEnabled(level: MJLLogLevel, category: LogCategory) -> Bool {
		return level.rawValue <= globalLevel.rawValue
	}
	
	public func description(logLevel: MJLLogLevel) -> NSAttributedString {
		if let customDesc = levelDescriptions?[logLevel] { return customDesc }
		return NSAttributedString(string: logLevel.description)
	}
}
