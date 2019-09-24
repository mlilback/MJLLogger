//
//  LogLevel.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation

/// Levels of log messages in decreasing importance
///
/// - error: a serious error
/// - warn: a warning about possible incorrect behavior
/// - info: an informative message
/// - debug: a message only relevant while debugging
/// - enter: a notice of enter a function
/// - exit: a notice of exiting a function
public enum LogLevel: Int, Comparable, CustomStringConvertible, Codable, CaseIterable {
	/// for SwiftLog compatibility
	case critical = 1
	case error
	case warn
	/// for SwiftLog compatibility
	case notice
	case info
	case debug
//	case enter
//	case exit
	/// for SwiftLog compatibility
	case trace
	
	public var description: String {
		switch self {
		case .critical: return "‼️ CRITICAL"
		case .error: return "🛑 ERROR"
		case .warn: return "⚠️ WARN"
		case .notice: return "📝 NOTICE"
		case .info: return "ℹ️ INFO"
		case .debug: return "🐞 DEBUG"
		case .trace: return "🧵 TRACE"
//		case .enter: return "→ ENTER"
//		case .exit: return "← EXIT"
		}
	}
	public static func <(lhs: LogLevel, rhs: LogLevel) -> Bool {
		return lhs.rawValue < rhs.rawValue
	}
}
