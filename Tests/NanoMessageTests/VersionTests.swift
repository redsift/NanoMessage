/*
    VersionTests.swift

    Copyright (c) 2016, 2017 Stephen Whittle  All rights reserved.

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"),
    to deal in the Software without restriction, including without limitation
    the rights to use, copy, modify, merge, publish, distribute, sublicense,
    and/or sell copies of the Software, and to permit persons to whom
    the Software is furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
    THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
    IN THE SOFTWARE.
*/

import XCTest

import NanoMessage

class VersionTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testNanoMsgABIVersion() {
         XCTAssertEqual(nanoMsgABIVersion.current, 5, "nanomsg ABI current of \(nanoMsgABIVersion.current) not as expected!")
         XCTAssertEqual(nanoMsgABIVersion.revision, 0, "nanomsg ABI revision of \(nanoMsgABIVersion.revision) not as expected!")
         XCTAssertEqual(nanoMsgABIVersion.age, 0, "nanomsg ABI age of \(nanoMsgABIVersion.age) not as expected!")

         print("current: \(nanoMsgABIVersion.current), revision: \(nanoMsgABIVersion.revision), age: \(nanoMsgABIVersion.age)")
    }

    func testNanoMessageVersion() {
         XCTAssertEqual(nanoMessageVersion.major, 0, "NanoMessage major of \(nanoMessageVersion.major) not as expected!")
         XCTAssertEqual(nanoMessageVersion.minor, 3, "NanoMessage minor of \(nanoMessageVersion.minor) not as expected!")
         XCTAssertGreaterThanOrEqual(nanoMessageVersion.patch, 4, "NanoMessage patch of \(nanoMessageVersion.patch) not as expected!")

         print("major: \(nanoMessageVersion.major), minor: \(nanoMessageVersion.minor), patch: \(nanoMessageVersion.patch)")
    }

#if os(Linux)
    static let allTests = [
        ("testNanoMsgABIVersion", testNanoMsgABIVersion),
        ("testNanoMessageVersion", testNanoMessageVersion)
    ]
#endif
}
