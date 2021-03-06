/*
    Message.swift

    Copyright (c) 2017 Stephen Whittle  All rights reserved.

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
import ISFLibrary
import FNVHashValue

public struct Message {
    internal private(set) var topic: Topic? = nil

    public let data: Data
    public var encoding: String.Encoding = NanoMessage.stringEncoding
    public var string: String {
        return (data.count == 0) ? "" : String(data: data, encoding: encoding)!
    }

    public init() {
        data = Data()
    }

    public init(value: Data) {
        data = value
    }

    public init(value: String, encoding: String.Encoding = NanoMessage.stringEncoding) {
        self.init(value: value.data(using: encoding)!)
        self.encoding = encoding
    }

    public init(value: Array<Byte>) {
        self.init(value: Data(bytes: value))
    }

    public init(topic: Topic, message: Data) {
        self.init(value: message)
        self.topic = topic
    }

    public init(topic: Topic, message: String, encoding: String.Encoding = NanoMessage.stringEncoding) {
        self.init(topic: topic, message: message.data(using: encoding)!)
        self.encoding = encoding
    }

    internal init(buffer: UnsafeMutableBufferPointer<Byte>) {
        self.init(value: Data(bytes: Array(buffer)))
    }
}

extension Message {
    public var isEmpty: Bool {
        return data.isEmpty
    }

    public var count: Int {
        return data.count
    }
}

extension Message: Hashable {
    public var hashValue: Int {
        if let unwrappedTopic = topic {
            return fnv1a(unwrappedTopic.data + data)
        }

        return fnv1a(data)
    }
}

extension Message: Comparable {
    public static func <(lhs: Message, rhs: Message) -> Bool {
        if let lhsTopic = lhs.topic, let rhsTopic = rhs.topic {
            return (lhsTopic == rhsTopic && lhs.data < rhs.data)
        }

        return (lhs.data < rhs.data)
    }
}

extension Message: Equatable {
    public static func ==(lhs: Message, rhs: Message) -> Bool {
        if let lhsTopic = lhs.topic, let rhsTopic = rhs.topic {
            return (lhsTopic == rhsTopic && lhs.data == rhs.data)
        }

        return (lhs.data == rhs.data)
    }
}

extension Message: CustomStringConvertible {
    public var description: String {
        var description = ""

        if let unwrappedTopic = topic {
            description = "topic: \(unwrappedTopic), "
        }

        description += "string: \(string), encoding: \(encoding)"

        return description
    }
}
