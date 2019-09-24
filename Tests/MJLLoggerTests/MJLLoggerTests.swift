import XCTest
@testable import MJLLogger
import Logging

public class StringOutputStream: TextOutputStream {
	var buffer: String = ""
	
	public func write(_ string: String) {
		print("adding \(string)")
		buffer += string
	}
}

class MJLLoggerTests: XCTestCase {

	func testFormatting() {
		let stream = StringOutputStream()
		let config = DefaultLogConfiguration(level: .debug)
		let handler = TextStreamHandler(stream: stream, config: config)
		let logger = MJLLogger(config: config)
		logger.append(handler: handler)
		Log.enableLogging(logger)
		
		Log.warn("foobar")
		print("buffer = \(stream.buffer)")
		XCTAssertTrue(stream.buffer.trimmingCharacters(in: .whitespacesAndNewlines).hasSuffix("foobar"))
		
		// test SwiftLogging
		LoggingSystem.bootstrap { label in
			Log.createSwiftLogger(label: label)
		}
		var slogger = Logger(label: "test")
		slogger[metadataKey: "category"] = "app"
		slogger.info("tested WITH CAT")
		slogger.debug("NEVER DOG") // should not be logged because of level
		XCTAssertNotNil(stream.buffer.range(of: "WITH CAT"))
		XCTAssertNil(stream.buffer.range(of: "NEVER DOG"))
	}


	static var allTests = [
		("testFormatting", testFormatting),
	]
}
