//
//  LogCategory.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import Foundation

/// A structure used to categorize a log entry. Users should extend the structure by adding static instances like the general one that is already declared.
public struct LogCategory: RawRepresentable, Hashable {
	
	/// The default category used by default
	public static let general: LogCategory = LogCategory("general")
	/// The raw string describing this category
	public let rawValue: String
	
	/// The init method required by RawRepresentable. In this case, it will never return nil.
	public init?(rawValue: String) {
		self.rawValue = rawValue
	}
	
	/// A default, unfailable init method
	///
	/// - Parameter value: the string describing the category
	public init(_ value: String) {
		self.rawValue = value
	}
	
	public var hashValue: Int { return rawValue.hashValue }
	
	public static func == (lhs: LogCategory, rhs: LogCategory) -> Bool {
		return lhs.rawValue == rhs.rawValue
	}
}

