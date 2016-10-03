/*
    Copyright (c) 2016 Stephen Whittle  All rights reserved.

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

@testable import NanoMessage

class SurveyProtocolFamilyTests: XCTestCase {
    private func testPair(connectAddress: String, bindAddress: String = "") {
        let bAddress = (bindAddress == "") ? connectAddress : bindAddress

        var completed = false

        do {
            print("survey with deadline reached...")

            let node0 = try SurveyorSocket()
            let node1 = try RespondentSocket()

            let node0EndPointId: Int = try node0.connectToAddress(connectAddress)
            XCTAssertGreaterThanOrEqual(node0EndPointId, 0, "node0.connectToAddress(endPointAddress: '\(connectAddress)') < 0")

            try node0.setDeadline(milliseconds: 1000)

            let node1EndPointId: Int = try node1.bindToAddress(bAddress)
            XCTAssertGreaterThanOrEqual(node1EndPointId, 0, "node1.bindToAddress(endPointAddress: '\(bAddress)') < 0")

            sleep(1)    // give nn_bind a chance to asynchronously bind to the port

            var bytesSent = try node0.sendMessage(payload)
            XCTAssertEqual(bytesSent, payload.utf8.count, "node0.bytesSent != payload.utf8.count")

            sleep(2)    // sleep for 2 second, deadline is 1 second, will cause node0.receiveMessage() to timeout.

            var node1Received: (bytes: Int, message: String) = try node1.receiveMessage()
            XCTAssertEqual(node1Received.bytes, node1Received.message.utf8.count, "node1.bytes != message.utf8.count")
            XCTAssertEqual(node1Received.message, payload, "node1.message != payload")

            bytesSent = try node1.sendMessage(payload)
            XCTAssertEqual(bytesSent, payload.utf8.count, "node1.bytesSent != payload.utf8.count")

            do {
                var _: (Int, String) = try node0.receiveMessage()
                XCTAssert(false, "received a message on node0")
            } catch NanoMessageError.Error(let errorNumber, let errorMessage) {
                if (errorNumber != 3) {
                    throw NanoMessageError(errorNumber: errorNumber, errorMessage: errorMessage)
                }
                XCTAssertEqual(errorNumber, 3, "\(errorMessage) (#\(errorNumber))")   // have we timedout
            }

            completed = true
        } catch NanoMessageError.nanomsgError(let errorNumber, let errorMessage) {
            XCTAssert(false, "\(errorMessage) (#\(errorNumber))")
        } catch NanoMessageError.Error(let errorNumber, let errorMessage) {
            XCTAssert(false, "\(errorMessage) (#\(errorNumber))")
        } catch (let errorMessage) {
            XCTAssert(false, "An Unknown error '\(errorMessage)' has occured in the library NanoMessage.")
        }

        XCTAssert(completed, "test not completed")
    }

    func testTCPSurvey() {
        print("TCP tests...")
        testPair(connectAddress: "tcp://localhost:5555", bindAddress: "tcp://*:5555")
    }

    func testInProcessSurvey() {
        print("In-Process tests...")
        testPair(connectAddress: "inproc:///tmp/pipeline.inproc")
    }

    func testInterProcessSurvey() {
        print("Inter Process tests...")
        testPair(connectAddress: "ipc:///tmp/pipeline.ipc")
    }

    func testWebSocketSurvey() {
        print("Web Socket tests...")
        testPair(connectAddress: "ws://localhost:5555", bindAddress: "ws://*:5555")
    }

#if !os(OSX)
    static let allTests = [
        ("testTCPSurvey", testTCPSurvey),
        ("testInProcessSurvey", testInProcessSurvey),
        ("testInterProcessSurvey", testInterProcessSurvey),
        ("testWebSocketSurvey", testWebSocketSurvey)
    ]
#endif
}