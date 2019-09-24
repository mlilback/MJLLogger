//
//  SwiftLogHandler.swift
//  MJLLogger
//
//  Created by Mark Lilback on 9/24/19.
//

import Foundation
import Logging

/// An implementation of a swift-log LogHandler that just forwards to a MJLLogger
public struct SwiftLogHandler: LogHandler {
	public weak var mjlLogger: MJLLogger?
	public let label: String
	
	public init(label: String, logger: MJLLogger) {
		self.label = label
		mjlLogger = logger
	}
	
	public func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, file: String, function: String, line: UInt)
	{
		let catStr = metadata?["category"]?.description ?? "general"
		let entry = LogEntry(type: .entry, message: message.description, level: MJLLogLevel(level: level), category: LogCategory(catStr), function: function, line: Int(line), fileName: file)
		mjlLogger?.log(entry)
	}
	
	public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
		get {
			return metadata[key]
		}
		set(newValue) {
			metadata[key] = newValue
		}
	}
	
	public var metadata: Logger.Metadata = [:]
	
	public var logLevel: Logger.Level = .info
	
	
}
