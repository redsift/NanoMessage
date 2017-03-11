/*
    Topic.swift

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

public struct Topic {
    public private(set) var data: Data
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
        self.encoding = encoding
        data = value.data(using: encoding)!
    }

    public init(value: [Byte]) {
        data = Data(bytes: value)
    }
}

extension Topic {
    public var isEmpty: Bool {
        return data.isEmpty
    }

    public var count: Int {
        return data.count
    }
}

extension Topic: Hashable {
    public var hashValue: Int {
        return fnv1a(data)
    }
}

extension Topic: Comparable {
    public static func <(lhs: Topic, rhs: Topic) -> Bool {
        return (compare(lhs: lhs.data, rhs: rhs.data) == .LessThan)
    }
}

extension Topic: Equatable {
    public static func ==(lhs: Topic, rhs: Topic) -> Bool {
        return (lhs.data == rhs.data)
    }
}
