//===------------------------------------------------------------------------------------===//
//
// This source file is part of the SwiftTencentSCFRuntime open source project
//
// Copyright (c) 2020 stevapple and the SwiftTencentSCFRuntime project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftTencentSCFRuntime project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===------------------------------------------------------------------------------------===//
//
// This source file was part of the SwiftAWSLambdaRuntime open source project
//
// Copyright (c) 2017-2020 Apple Inc. and the SwiftAWSLambdaRuntime project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See http://github.com/swift-server/swift-aws-lambda-runtime/blob/master/CONTRIBUTORS.txt
// for the list of SwiftAWSLambdaRuntime project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===------------------------------------------------------------------------------------===//

import struct Foundation.Date
import class Foundation.DateFormatter
import class Foundation.ISO8601DateFormatter
import struct Foundation.Locale

@propertyWrapper
public struct ISO8601Coding: Decodable {
    public let wrappedValue: Date

    public init(wrappedValue: Date) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)
        guard let date = Self.dateFormatter.date(from: dateString) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription:
                "Expected date to be in iso8601 date format, but `\(dateString)` does not forfill format")
        }
        self.wrappedValue = date
    }

    private static let dateFormatter = ISO8601DateFormatter()
}

@propertyWrapper
public struct ISO8601WithFractionalSecondsCoding: Decodable {
    public let wrappedValue: Date

    public init(wrappedValue: Date) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)
        guard let date = Self.dateFormatter.date(from: dateString) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription:
                "Expected date to be in iso8601 date format with fractional seconds, but `\(dateString)` does not forfill format")
        }
        self.wrappedValue = date
    }

    private static let dateFormatter: ISO8601DateFormatter = Self.createDateFormatter()
    private static func createDateFormatter() -> ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime,
            .withDashSeparatorInDate,
            .withColonSeparatorInTime,
            .withColonSeparatorInTimeZone,
            .withFractionalSeconds,
        ]
        return formatter
    }
}

@propertyWrapper
public struct RFC5322DateTimeCoding: Decodable {
    public let wrappedValue: Date

    public init(wrappedValue: Date) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        var string = try container.decode(String.self)
        // RFC5322 dates sometimes have the alphabetic version of the timezone in brackets after the numeric version. The date formatter
        // fails to parse this so we need to remove this before parsing.
        if let bracket = string.firstIndex(of: "(") {
            string = String(string[string.startIndex ..< bracket].trimmingCharacters(in: .whitespaces))
        }
        guard let date = Self.dateFormatter.date(from: string) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription:
                "Expected date to be in RFC5322 date-time format with fractional seconds, but `\(string)` does not forfill format")
        }
        self.wrappedValue = date
    }

    private static let dateFormatter: DateFormatter = Self.createDateFormatter()
    private static func createDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, d MMM yyy HH:mm:ss z"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
}
