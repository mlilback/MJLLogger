//
//  LogBucker.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation
import Logging

/// A class containing singleton access to the logging system
public final class Log {
	/// The singleton Logger instance. Can only be set once via enableLogging()
	public private(set) static var logger: MJLLogger?
	/// A flag to track if the logger has been set
	private static var loggerSet: Bool = false
	
	/// Setup the Logger to use. Repeated calls are ignored
	public static func enableLogging(_ logger: MJLLogger?) {
		guard !loggerSet else { return }
		loggerSet = true
		self.logger = logger
	}
	
	/// Creates a Logging.LogHandler. Serves as a  factory function for LoggingSystem.bootstrap
	/// e.g. `LoggingSystem.bootstrap(Log.createSwiftLogger)`
	///
	/// - Parameter label: The label for the handler to create
	///
	/// - Returns: a Logging.LogHandler
	public static func createSwiftLogger(label: String) -> LogHandler {
		guard let log = logger else { fatalError("logging was not enabled") }
		return SwiftLogHandler(label: label, logger: log)
	}

	public static func isLogging(_ level: MJLLogLevel, category: LogCategory = .general) -> Bool {
		return (logger?.logEverything ?? false) || (logger?.configuration.loggingEnabled(level: level, category: category) ?? false)
	}
	
	public static func error(_ message: String, _ category: LogCategory = .general, function: String = #function, lineNumber: Int = #line, fileName: String = #file)
	{
		logger?.log(LogEntry(message: message, level: .error, category: category, function: function, line: lineNumber, fileName: fileName))
	}

	public static func warn(_ message: String, _ category: LogCategory = .general, function: String = #function, lineNumber: Int = #line, fileName: String = #file)
	{
		guard isLogging(.warn, category: category) else { return }
		logger?.log(LogEntry(message: message, level: .warn, category: category, function: function, line: lineNumber, fileName: fileName))
	}

	public static func notice(_ message: String, _ category: LogCategory = .general, function: String = #function, lineNumber: Int = #line, fileName: String = #file)
	{
		guard isLogging(.notice, category: category) else { return }
		logger?.log(LogEntry(message: message, level: .notice, category: category, function: function, line: lineNumber, fileName: fileName))
	}

	public static func info(_ message: String, _ category: LogCategory = .general, function: String = #function, lineNumber: Int = #line, fileName: String = #file)
	{
		guard isLogging(.info, category: category) else { return }
		logger?.log(LogEntry(message: message, level: .info, category: category, function: function, line: lineNumber, fileName: fileName))
	}

	public static func debug(_ message: String, _ category: LogCategory = .general, function: String = #function, lineNumber: Int = #line, fileName: String = #file)
	{
		guard isLogging(.debug, category: category) else { return }
		logger?.log(LogEntry(message: message, level: .debug, category: category, function: function, line: lineNumber, fileName: fileName))
	}

	public static func trace(_ message: String, _ category: LogCategory = .general, function: String = #function, lineNumber: Int = #line, fileName: String = #file)
	{
		guard isLogging(.trace, category: category) else { return }
		logger?.log(LogEntry(message: message, level: .trace, category: category, function: function, line: lineNumber, fileName: fileName))
	}

	@available(*, deprecated)
	public static func enter(_ category: LogCategory = .general, function: String = #function, lineNumber: Int = #line, fileName: String = #file)
	{
		guard isLogging(.trace, category: category) else { return }
		logger?.log(LogEntry(message: "", level: .trace, category: category, function: function, line: lineNumber, fileName: fileName))
	}
	
	@available(*, deprecated)
	public static func exit(_ category: LogCategory = .general, function: String = #function, lineNumber: Int = #line, fileName: String = #file)
	{
		guard isLogging(.trace, category: category) else { return }
		logger?.log(LogEntry(message: "", level: .trace, category: category, function: function, line: lineNumber, fileName: fileName))
	}
}

