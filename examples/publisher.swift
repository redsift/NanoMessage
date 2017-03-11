/*
    publisher.swift

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

import NanoMessage
import Foundation
import ISFLibrary
import FNVHashValue

struct DataSet: Hashable {
    let topic: String
    let message: String

    init(topic: String, message: String) {
        self.topic = topic
        self.message = message
    }

    var hashValue: Int {
        return fnv1a(self.topic + self.message)
    }

    static func ==(lhs: DataSet, rhs: DataSet) -> Bool {
        return (lhs.topic == rhs.topic && lhs.message == rhs.message)
    }
}

var urlToUse = "tcp://localhost:5555"

switch (CommandLine.arguments.count) {
    case 1:
        break
    case 2:
        urlToUse = CommandLine.arguments[1]
    default:
        fatalError("usage: publisher [url]")
}

guard let url = URL(string: urlToUse) else {
    fatalError("url is not valid")
}

do {
    var messages = Set<DataSet>()

    messages.insert(DataSet(topic: "interesting", message: "this is message #1"))
    messages.insert(DataSet(topic: "not-really",  message: "this is message #2"))
    messages.insert(DataSet(topic: "interesting", message: "this is message #3"))
    messages.insert(DataSet(topic: "interesting", message: "this is message #4"))

    let node0 = try PublisherSocket()

    let endPoint: EndPoint = try node0.createEndPoint(url: url, type: .Connect)

    usleep(TimeInterval(seconds: 0.25))

    print(endPoint)

    for dataSet in messages.sorted(by: { $0.message < $1.message }) {
        let topic = Topic(value: dataSet.topic)
        let message = Message(value: dataSet.message)

        try node0.setSendTopic(topic)

        print("sending topic: \(topic.string), message: \(message.string)")

        try node0.sendMessage(message, timeout: TimeInterval(seconds: 10))
    }

    print("messages sent: \(node0.messagesSent!)")
    print("bytes sent   : \(node0.bytesSent!)")
} catch let error as NanoMessageError {
    print(error, to: &errorStream)
} catch {
    print("an unexpected error '\(error)' has occured in the library libNanoMessage.", to: &errorStream)
}

exit(EXIT_SUCCESS)
