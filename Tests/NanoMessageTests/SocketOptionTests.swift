/*
    SocketOptionTests.swift

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

import NanoMessage

class SocketOptionTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSocketOptions() {
        var completed = false

        do {
            let node0 = try PairSocket()

            XCTAssertEqual(node0.domain, SocketDomain.StandardSocket, "node0.socketDomain: \(node0.domain)")
            XCTAssertEqual(node0.protocol, SocketProtocol.PairProtocol, "node0.socketProtocol: \(node0.protocol)")
            XCTAssertEqual(node0.protocolFamily, ProtocolFamily.OneToOne, "node0.socketProtocolFamily: \(node0.protocolFamily)")

            let linger = try node0.getLinger()
            XCTAssertEqual(linger, 1, "getLinger(): \(linger)")
            var sendBufferSize = try node0.getSendBufferSize()
            XCTAssertEqual(sendBufferSize, 131072, "getSendBufferSize(): \(sendBufferSize)")
            var receiveBufferSize = try node0.getReceiveBufferSize()
            XCTAssertEqual(receiveBufferSize, 131072, "getReceiveBufferSize(): \(receiveBufferSize)")
            var sendTimeout = try node0.getSendTimeout()
            XCTAssertEqual(sendTimeout, -1, "getSendTimeout(): \(sendTimeout)")
            let maximumMessageSize = try node0.getMaximumMessageSize()
            XCTAssertEqual(maximumMessageSize, 1048576, "getSendTimeout(): \(sendTimeout)")
            var receiveTimeout = try node0.getReceiveTimeout()
            XCTAssertEqual(receiveTimeout, -1, "getReceiveTimeout(): \(receiveTimeout)")
            var reconnectInterval = try node0.getReconnectInterval()
            XCTAssertEqual(reconnectInterval, 0.1, "getReconnectInterval(): \(reconnectInterval)")
            var reconnectIntervalMaximum = try node0.getReconnectIntervalMaximum()
            XCTAssertEqual(reconnectIntervalMaximum, 0, "getReconnectIntervalMaximum(): \(reconnectIntervalMaximum)")
            var sendPriority = try node0.getSendPriority()
            XCTAssertEqual(sendPriority, Priority(level: 8), "getSendPriority(): \(sendPriority)")
            var receivePriority = try node0.getReceivePriority()
            XCTAssertEqual(receivePriority, Priority(level: 8), "getReceivePriority(): \(receivePriority)")
            let sendFileDescriptor = try node0.getSendFileDescriptor()
            print("getSendFileDescriptor(): \(sendFileDescriptor)")
            let receiveFileDescriptor = try node0.getReceiveFileDescriptor()
            print("getReceiveFileDescriptor(): \(receiveFileDescriptor)")
            var socketName = try node0.getSocketName()
            print("getSocketName(): \(socketName)")
            var ipv4Only = try node0.getIPv4Only()
            XCTAssertEqual(ipv4Only, true, "getIPv4Only(): \(ipv4Only)")
            var maximumTTL = try node0.getMaximumTTL()
            XCTAssertEqual(maximumTTL, 8, "getMaximumTTL(): \(maximumTTL)")
            var TCPNoDelay = try node0.getTCPNoDelay(transportMechanism: .TCP)
            XCTAssertEqual(TCPNoDelay, false, "getTCPNoDelay(.TCP): \(TCPNoDelay)")
            var WSNoDelay = try node0.getTCPNoDelay(transportMechanism: .WebSocket)
            XCTAssertEqual(WSNoDelay, false, "getTCPNoDelay(.WebSocket): \(TCPNoDelay)")
            var WSMessageType = try node0.getWebSocketMessageType()
            XCTAssertEqual(WSMessageType, WebSocketMessageType.BinaryFrames, "getWebSocketMessageType: \(WSMessageType)")


            try node0.setSendBufferSize(bytes: 1024)
            sendBufferSize = try node0.getSendBufferSize()
            XCTAssertEqual(sendBufferSize, 1024, "set->getSendBufferSize(): \(sendBufferSize)")
            try node0.setReceiveBufferSize(bytes: 2048)
            receiveBufferSize = try node0.getReceiveBufferSize()
            XCTAssertEqual(receiveBufferSize, 2048, "set->getReceiveBufferSize(): \(receiveBufferSize)")
            try node0.setSendTimeout(seconds: 1)
            sendTimeout = try node0.getSendTimeout()
            XCTAssertEqual(sendTimeout, 1, "set->getSendTimeout(): \(sendTimeout)")
            try node0.setReceiveTimeout(seconds: 0.5)
            receiveTimeout = try node0.getReceiveTimeout()
            XCTAssertEqual(receiveTimeout, 0.5, "set->getReceiveTimeout(): \(receiveTimeout)")
            try node0.setReconnectInterval(seconds: 0.2)
            reconnectInterval = try node0.getReconnectInterval()
            XCTAssertEqual(reconnectInterval, 0.2, "set->getReconnectInterval(): \(reconnectInterval)")
            try node0.setReconnectIntervalMaximum(seconds: 0.1)
            reconnectIntervalMaximum = try node0.getReconnectIntervalMaximum()
            XCTAssertEqual(reconnectIntervalMaximum, 0.1, "set->getReconnectIntervalMaximum(): \(reconnectIntervalMaximum)")
            try node0.setSendPriority(Priority(level: 1))
            sendPriority = try node0.getSendPriority()
            XCTAssertEqual(sendPriority, Priority(level: 1), "set->getSendPriority(): \(sendPriority)")
            try node0.setReceivePriority(Priority(level: 2))
            receivePriority = try node0.getReceivePriority()
            XCTAssertEqual(receivePriority, Priority(level: 2), "set->getReceivePriority(): \(receivePriority)")
            try node0.setSocketName("test")
            socketName = try node0.getSocketName()
            XCTAssertEqual(socketName, "test", "set->getSocketName(): \(socketName)")
            try node0.setIPv4Only(false)
            ipv4Only = try node0.getIPv4Only()
            XCTAssertEqual(ipv4Only, false, "set->getIPv4Only(): \(ipv4Only)")
            try node0.setMaximumTTL(hops: 4)
            maximumTTL = try node0.getMaximumTTL()
            XCTAssertEqual(maximumTTL, 4, "set->getMaximumTTL(): \(maximumTTL)")
            try node0.setTCPNoDelay(disableNagles: true, transportMechanism: .TCP)
            TCPNoDelay = try node0.getTCPNoDelay(transportMechanism: .TCP)
            XCTAssertEqual(TCPNoDelay, true, "set->getTCPNoDelay(.TCP): \(TCPNoDelay)")
            try node0.setTCPNoDelay(disableNagles: true, transportMechanism: .WebSocket)
            WSNoDelay = try node0.getTCPNoDelay(transportMechanism: .WebSocket)
            XCTAssertEqual(WSNoDelay, true, "set->getTCPNoDelay(.WebSocket): \(TCPNoDelay)")
            try node0.setWebSocketMessageType(.TextFrames)
            WSMessageType = try node0.getWebSocketMessageType()
            XCTAssertEqual(WSMessageType, WebSocketMessageType.TextFrames, "set->getWebSocketMessageType: \(WSMessageType)")

            let node1 = try RequestSocket()

            var resendInterval = try node1.getResendInterval()
            XCTAssertEqual(resendInterval, 60, "getResendInterval(): \(resendInterval)")

            try node1.setResendInterval(seconds: 30.5)
            resendInterval = try node1.getResendInterval()
            XCTAssertEqual(resendInterval, 30.5, "set->getResendInterval(): \(resendInterval)")

            let node2 = try SurveyorSocket()

            var deadline = try node2.getDeadline()
            XCTAssertEqual(deadline, 1, "getDeadline(): \(deadline)")

            try node2.setDeadline(seconds: 2)
            deadline = try node2.getDeadline()
            XCTAssertEqual(deadline, 2, "set->getDeadline(): \(deadline)")

            completed = true
        } catch let error as NanoMessageError {
            XCTAssert(false, "\(error)")
        } catch {
            XCTAssert(false, "an unexpected error '\(error)' has occured in the library libNanoMessage.")
        }

        XCTAssert(completed, "test not completed")
    }

    func testSocketOption() {
        testSocketOptions()
    }

#if os(Linux)
    static let allTests = [
        ("testSocketOption", testSocketOption)
    ]
#endif
}
