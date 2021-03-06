/*
    PollSocketTests.swift

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
import Foundation
import ISFLibrary

import NanoMessage

class PollSocketTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testPollSocket(connectAddress: String, bindAddress: String = "") {
        guard let connectURL = URL(string: connectAddress) else {
            XCTAssert(false, "connectURL is invalid")
            return
        }

        guard let bindURL = URL(string: (bindAddress.isEmpty) ? connectAddress : bindAddress) else {
            XCTAssert(false, "bindURL is invalid")
            return
        }

        var completed = false

        do {
            let node0 = try PushSocket()
            let node1 = try PullSocket()

            try node0.setSendTimeout(seconds: 1)
            try node1.setReceiveTimeout(seconds: 1)

            let node0EndPointId: Int = try node0.createEndPoint(url: connectURL, type: .Connect)
            XCTAssertGreaterThanOrEqual(node0EndPointId, 0, "node0.createEndPoint('\(connectURL)', .Connect) < 0")

            let node1EndPointId: Int = try node1.createEndPoint(url: bindURL, type: .Bind)
            XCTAssertGreaterThanOrEqual(node1EndPointId, 0, "node1.createEndPoint('\(bindURL)', .Bind) < 0")

            pauseForBind()

            var node1Poll: PollResult = try node1.pollSocket(timeout: 0.5)
            XCTAssertEqual(node1Poll.messageIsWaiting, false, "node1Poll.messageIsWaiting != false")
            XCTAssertEqual(node1Poll.sendIsBlocked, false, "node1Poll.sendIsBlocked != false")

            let sent = try node0.sendMessage(payload)
            XCTAssertEqual(sent.bytes, payload.count, "sent.bytes != payload.count")

            usleep(TimeInterval(milliseconds: 50))          // pause to make sure the message is sent.

            let pollResults = try poll(sockets: [node0, node1], timeout: 0.5)
            XCTAssertEqual(pollResults[0].messageIsWaiting, false, "pollResults[0].messageIsWaiting != false")
            XCTAssertEqual(pollResults[0].sendIsBlocked, true, "pollResults[0].sendIsBlocked != true")
            XCTAssertEqual(pollResults[1].messageIsWaiting, true, "pollResults[1].messageIsWaiting != true")
            XCTAssertEqual(pollResults[1].sendIsBlocked, false, "pollResults[1].sendIsBlocked != false")

            let node1Received = try node1.receiveMessage()
            XCTAssertEqual(node1Received.bytes, node1Received.message.count, "bytes != node1Received.message.count")
            XCTAssertEqual(node1Received.message, payload, "message != payload")

            let node0Poll = try node0.pollSocket(timeout: 0.25)
            XCTAssertEqual(node0Poll.messageIsWaiting, false, "node0Poll.messageIsWaiting != false")
            XCTAssertEqual(node0Poll.sendIsBlocked, true, "node0Poll.sendIsBlocked != true")

            node1Poll = try node1.pollSocket(timeout: 0.25)
            XCTAssertEqual(node1Poll.messageIsWaiting, false, "node1Poll.messageIsWaiting != false")
            XCTAssertEqual(node1Poll.sendIsBlocked, false, "node1Poll.sendIsBlocked != false")

            completed = true
        } catch let error as NanoMessageError {
            XCTAssert(false, "\(error)")
        } catch {
            XCTAssert(false, "an unexpected error '\(error)' has occured in the library libNanoMessage.")
        }

        XCTAssert(completed, "test not completed")
    }

    func testTCPPollSocket() {
        testPollSocket(connectAddress: "tcp://localhost:5600", bindAddress: "tcp://*:5600")
    }

    func testInProcessPollSocket() {
        testPollSocket(connectAddress: "inproc:///tmp/poll.inproc")
    }

    func testInterProcessPollSocket() {
        testPollSocket(connectAddress: "ipc:///tmp/poll.ipc")
    }

    func testWebSocketPollSocket() {
        testPollSocket(connectAddress: "ws://localhost:5605", bindAddress: "ws://*:5605")
    }

#if os(Linux)
    static let allTests = [
        ("testTCPPollSocket", testTCPPollSocket),
        ("testInProcessPollSocket", testInProcessPollSocket),
        ("testInterProcessPollSocket", testInterProcessPollSocket),
        ("testWebSocketPollSocket", testWebSocketPollSocket)
    ]
#endif
}
