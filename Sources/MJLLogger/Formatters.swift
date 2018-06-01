//
//  Formatters.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation
#if os(OSX)
import os
#endif
import Dispatch

fileprivate func log_error(_ message: String) {
	#if os(Linux)
		FileHandle.standardError.write(message.data(using: .utf8)!)
	#else 
		os_log("%{public}@", message)
	#endif
}

public protocol LogFormatter {
	/// the configuration to use
	var config: LogConfiguration { get }
	/// formats the entry as plain text
	func format(entry: LogEntry) -> String?
	/// formats the entry as an attributed string. by default, just returns plain text string as an attributed string
	func formatWithAttributes(entry: LogEntry) -> NSAttributedString?
}

// MARK: -

/// Tokens that can be parsed from a format string
///
/// - date: "(%date)" is replaced with the date/time of the log entry
/// - level: "(%level)" is replaced with the log level
/// - category: "(%category)" is replaced with the category description
/// - message: "(%message)" is replaced with the entry's message
/// - file: "(%file)" is replaced with the path of the source file
/// - filename: "(%filename)" is replaced with the last path component (i.e. the name) of the source file
/// - line: "(%line)" is replaced with the line number of the log call
/// - function: "(%function)" is replaced with the name of the function that made the log entry
/// - type: "(%type%)" is replaced with the entry type (entry or start). Formatters are free to write any value they want, but should document what is used
public enum LogFormatToken: String {
	case date = "(%date)"
	case level = "(%level)"
	case category = "(%category)"
	case message = "(%message)"
	case file = "(%file)"
	case shortFile = "(%filename)"
	case line = "(%line)"
	case function = "(%function)"
	case type = "(%type)"
}

/// a flexible LogFormatter using parsed tokens
public class TokenizedLogFormatter: LogFormatter {
	/// the default format string
	public static let defaultLogFormat = "(%type) (%date) (%level) (%category), (%function)[(%file):(%line)] (%message)"
	/// errors thrown by the tokenized log formatter
	public enum FormatterError: Error {
		case invalidFormat
	}
	
	enum Token {
		case text(NSAttributedString)
		case token(LogFormatToken)
	}
	
	/// performs basic parsing of tokens
	private static func parseTokens(formatString: NSAttributedString, dateFormatter: DateFormatterProtocol) throws -> [Token]
	{
		let regex = try NSRegularExpression(pattern: "\\(%\\w+\\)", options: .useUnicodeWordBoundaries)
		let nsFormatString = NSString(string: formatString.string)
		var parsedTokens = [Token]()
		var currentLocation = 0
		let matches = regex.matches(in: formatString.string, options: [], range: NSMakeRange(0, nsFormatString.length))
		for aMatch in matches {
			let loc = aMatch.range.location
			// if there is text before the match, add it as a text token
			if currentLocation < loc {
				let range = NSRange(location: currentLocation, length: loc - currentLocation)
				let startStr = formatString.attributedSubstring(from: range)
				parsedTokens.append(.text(startStr))
			}
			// parse the token
			currentLocation = aMatch.range.upperBound
			let matchedStr = nsFormatString.substring(with: aMatch.range)
			if let nextToken = LogFormatToken(rawValue: matchedStr) {
				// was a valid token
				parsedTokens.append(.token(nextToken))
			} else {
				// not a supported token name. just add the match as a text token
				parsedTokens.append(.text(NSAttributedString(string: matchedStr)))
			}
		}
		// if there was text after the last match, add it as a text token
		if currentLocation < nsFormatString.length {
			let range = NSRange(location: currentLocation, length: nsFormatString.length - currentLocation)
			let startStr = formatString.attributedSubstring(from: range)
			parsedTokens.append(.text(startStr))
		}
		return parsedTokens
	}
	
	public let config: LogConfiguration
	/// The format string that should contain LogFormatTokens
	public let formatString: NSAttributedString
	/// the attributes to use when formatting a particular token type as an attributed string
	public let tokenAttributes = [LogFormatToken: [NSAttributedStringKey: Any]]()

	let tokens: [Token]
	let dateFormatter: DateFormatterProtocol
	
	/// convience initialiizer to create a formatter from a plain string
	///
	/// - Parameters:
	///   - config: the log configuration to use
	///   - formatString: a string containing LogFormatTokens
	///   - dateFormatter: the date formatter to use
	public convenience init(config: LogConfiguration, formatString: String, dateFormatter: DateFormatterProtocol? = nil)
	{
		self.init(config: config, formatString: NSAttributedString(string: formatString), dateFormatter: dateFormatter)
	}
	
	/// Creates a formatter
	///
	/// - Parameters:
	///   - config: the log configuration to use
	///   - formatString: a string containing LogFormatTokens
	///   - dateFormatter: the date formatter to use
	public init(config: LogConfiguration, formatString: NSAttributedString? = nil, dateFormatter: DateFormatterProtocol? = nil)
	{
		self.config = config
		self.formatString = formatString ?? NSAttributedString(string: TokenizedLogFormatter.defaultLogFormat)
		self.dateFormatter = dateFormatter ?? ISO8601DateFormatter()
		do {
			self.tokens = try TokenizedLogFormatter.parseTokens(formatString: self.formatString, dateFormatter: self.dateFormatter)
		} catch {
			fatalError("error parsing format string: \(error)")
		}
	}
	
	/// formats entry as a string
	public func format(entry: LogEntry) -> String? {
		var str = ""
		for aToken in tokens {
			switch aToken {
			case .text(let text):
				str += text.string
			case .token(let formatToken):
				if let valueStr = value(for: formatToken, of: entry) {
					str += valueStr
				}
			}
		}
		return str
	}
	
	/// format entry as an NSAttributedString
	public func formatWithAttributes(entry: LogEntry) -> NSAttributedString? {
		let str = NSMutableAttributedString(string: "")
		var lastAttrs = [NSAttributedStringKey: Any]()
		for aToken in tokens {
			switch aToken {
			case .text(let text):
				str.append(text)
				// FIXME: once linux is using swift 4.1
				// the call to str.attributes accepts NSRangePointer? in swift 4 on OSX, but not on linux until 4.1. so use a dummpy range pointer
				var unusedRange: NSRange = NSRange(location: 0, length: text.length)
				lastAttrs = str.attributes(at: str.length - 1, effectiveRange: &unusedRange)
			case .token(let formatToken):
				guard let valueStr = attributedValue(for: formatToken, of: entry) else { break }
				str.append(valueStr)
				if lastAttrs.count > 0 {
					str.addAttributes(lastAttrs, range: NSRange(location: str.length - valueStr.length, length: valueStr.length))
				}
				if let attrs = tokenAttributes[formatToken] {
					str.addAttributes(attrs, range: NSRange(location: 0, length: str.length))
				}
			}
		}
		return str.length > 0 ? str : nil
	}
	
	func value(for token: LogFormatToken, of entry: LogEntry) -> String? {
		switch token {
		case .type:
			return entry.type.rawValue
		case .category:
			return entry.category.rawValue
		case .level:
			return config.description(logLevel: entry.level).string
		case .message:
			return entry.message
		case .date:
			return dateFormatter.string(from: entry.date)
		case .shortFile:
			if let fname = entry.fileName?.split(separator: "/").last {
				return String(fname)
			}
			return entry.fileName
		case .file:
			return entry.fileName
		case .line:
			if let line = entry.line { return String(line) }
			return nil
		case .function:
			return entry.function
		}
	}

	func attributedValue(for token: LogFormatToken, of entry: LogEntry) -> NSAttributedString? {
		switch token {
		case .type:
			return NSAttributedString(string: entry.type.rawValue)
		case .category:
			return NSAttributedString(string: entry.category.rawValue)
		case .level:
			return config.description(logLevel: entry.level)
		case .message:
			return NSAttributedString(string: entry.message)
		case .date:
			return NSAttributedString(string: dateFormatter.string(from: entry.date))
		case .shortFile:
			guard let filename = entry.fileName else { return nil }
			if let fname = filename.split(separator: "/").last {
				return NSAttributedString(string: String(fname))
			}
			return NSAttributedString(string: filename)
		case .file:
			guard let filename = entry.fileName else { return nil }
			return NSAttributedString(string: filename)
		case .line:
			guard let lineNum = entry.line else { return nil }
			return NSAttributedString(string: String(lineNum))
		case .function:
			guard let functionName = entry.function else { return nil }
			return NSAttributedString(string: functionName)
		}
	}
}

// MARK: - JSON Formtter

/// formats an entry into json format. dates are in ISO8601 format
public class JSONLogFormatter: LogFormatter {
	public var config: LogConfiguration
	public let encoder: JSONEncoder
	
	/// creates a formatter that formats entries as json
	public init(config: LogConfiguration) {
		self.config = config
		self.encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
	}
	
	public func format(entry: LogEntry) -> String? {
		do {
			let data = try encoder.encode(entry)
			guard let string = String(data: data, encoding: .utf8)
				else { log_error("Failed to encode LogEntry"); return nil }
			return string
		} catch {
			log_error("Failed to encode LogEntry: \(error.localizedDescription)")
		}
		return nil
	}
	
	public func formatWithAttributes(entry: LogEntry) -> NSAttributedString? {
		guard let string = format(entry: entry) else { return nil }
		return NSAttributedString(string: string)
	}
	
	
}

// MARK: - Foundation Date

/// A common protocol for all date formatters, which should really exist in Foundation
public protocol DateFormatterProtocol {
	func string(from: Date) -> String
}

extension DateFormatter: DateFormatterProtocol {}

//@available(OSX 10.12, *)
extension ISO8601DateFormatter: DateFormatterProtocol {}

