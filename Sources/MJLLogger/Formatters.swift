//
//  Formatters.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation

public protocol LogFormatter {
	func format(entry: LogEntry) -> String?
}

public enum LogFormatToken: String {
	case date = "(%date)"
	case level = "(%level)"
	case category = "(%category)"
	case message = "(%message)"
	case file = "(%file)"
	case line = "(%line)"
	case function = "(%function)"
}

public class TokenizedLogFormatter: LogFormatter {
	public enum FormatterError: Error {
		case invalidFormat
	}
	
	enum Token {
		case text(String)
		case token(LogFormatToken)
	}
	
	public let fmtString: String
	let tokens: [Token]
	let dateFormatter: DateFormatterProtocol
	
	public init(formatString: String? = nil, dateFormatter: DateFormatterProtocol? = nil) {
		self.fmtString = formatString ?? "[(%date)] [(%level)] [(%category)], [(%file):(%line):(%function)] (%message)"
		self.dateFormatter = dateFormatter ?? ISO8601DateFormatter()
		do {
		let regex = try NSRegularExpression(pattern: "\\(%\\w+\\)", options: .useUnicodeWordBoundaries)
		let nsFormatString = NSString(string: fmtString)
		var parsedTokens = [Token]()
		var currentLocation = 0
		let matches = regex.matches(in: fmtString, options: [], range: NSMakeRange(0, nsFormatString.length))
		for aMatch in matches {
			let loc = aMatch.range.location
			// if there is text before the match, add it as a text token
			if currentLocation < loc {
				let startStr = nsFormatString.substring(with: NSRange(location: currentLocation, length: loc - currentLocation))
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
				parsedTokens.append(.text(matchedStr))
			}
		}
		// if there was text after the last match, add it as a text token
		if currentLocation < nsFormatString.length {
			let endStr = nsFormatString.substring(from: currentLocation)
			parsedTokens.append(.text(endStr))
		}
		tokens = parsedTokens
		} catch {
			fatalError("error parsing format string: \(error)")
		}
	}
	
	public func format(entry: LogEntry) -> String? {
		var str = ""
		for aToken in tokens {
			switch aToken {
			case .text(let text):
				str += text
			case .token(let formatToken):
				str += value(for: formatToken, of: entry)
			}
		}
		return str
	}
	
	func value(for token: LogFormatToken, of entry: LogEntry) -> String {
		switch token {
			case .category:
				return entry.category.rawValue
			case .level:
				return entry.level.description
			case .message:
				return entry.message
			case .date:
				return dateFormatter.string(from: entry.date)
			case .file:
				if let fname = entry.fileName.split(separator: "/").last {
					return String(fname)
				}
				return "";
			case .line:
				return String(entry.line)
			case .function:
				return entry.function
		}
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

