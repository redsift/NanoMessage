/*
    subscriber.swift

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

import Foundation
import NanoMessage
import ISFLibrary

var urlToUse = "tcp://*:5555"

switch (CommandLine.arguments.count) {
    case 1:
        break
    case 2:
        urlToUse = CommandLine.arguments[1]
    default:
        fatalError("usage: subscriber [url]")
}

guard let url = URL(string: urlToUse) else {
    fatalError("url is not valid")
}

do {
    let node0 = try SubscriberSocket()
    let endPoint: EndPoint = try node0.bindToURL(url, name: "my local end-point")

    usleep(TimeInterval(seconds: 0.25))

    print(endPoint)

    try node0.subscribeTo(topic: Topic(value: "interesting"))

    while (true) {
        let received = try node0.receiveMessage(timeout: TimeInterval(seconds: 10))

        print("topic            : \(node0.receivedTopic)")
        print("message          : \(received.message.string)")
        print("bytes            : \(received.bytes)")

        let socket = try node0.pollSocket(timeout: TimeInterval(seconds: 0.25))

        if (!socket.messageIsWaiting) {
            break
        }
    }

    let messagesReceived = try node0.getMessagesReceived()
    let bytesReceived = try node0.getBytesReceived()

    print("messages received: \(messagesReceived)")
    print("bytes received   : \(bytesReceived)")
} catch let error as NanoMessageError {
    print(error, to: &errorStream)
} catch {
    print("an unexpected error '\(error)' has occured in the library libNanoMessage.", to: &errorStream)
}

exit(EXIT_SUCCESS)
