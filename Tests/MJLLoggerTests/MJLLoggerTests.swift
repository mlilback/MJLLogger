import XCTest
@testable import MJLLogger

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
		let logger = TextStreamLogger(stream: stream, config: config)
		Log.enableLogging(logger)
		
		Log.warn("foobar")
		XCTAssertTrue(stream.buffer.hasSuffix("foobar"))
	}


	static var allTests = [
		("testFormatting", testFormatting),
	]
}
