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

import struct Foundation.Date
import struct Foundation.URL

// https://cloud.tencent.com/document/product/583/9707

extension COS.Object: Codable {
    enum CodingKeys: String, CodingKey {
        case url
        case key
        case vid
        case size
        case meta
    }

    enum MetaCodingKeys: String, CodingKey {
        case contentType = "Content-Type"
        case cacheControl = "Cache-Control"
        case contentDisposition = "Content-Disposition"
        case contentEncoding = "Content-Encoding"
        case expireTime = "Expire-Time"
        case requestId = "x-cos-request-id"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        url = try container.decode(URL.self, forKey: .url)
        key = try container.decode(String.self, forKey: .key)
        vid = try container.decode(String.self, forKey: .vid)
        size = try container.decode(UInt64.self, forKey: .size)

        let metaContainer = try container.nestedContainer(keyedBy: MetaCodingKeys.self, forKey: .meta)
        contentType = try metaContainer.decodeIfPresent(String.self, forKey: .contentType)
        cacheControl = try metaContainer.decodeIfPresent(String.self, forKey: .cacheControl)
        contentDisposition = try metaContainer.decodeIfPresent(String.self, forKey: .contentDisposition)
        contentEncoding = try metaContainer.decodeIfPresent(String.self, forKey: .contentEncoding)
        requestId = try metaContainer.decodeIfPresent(String.self, forKey: .requestId)
        expireTime = try metaContainer.decodeIfPresent(Date.self, forKey: .expireTime, using: DateCoding.RFC5322.self)
        customMeta = try container.decode([String: String].self, forKey: .meta)
            .compactMapKeys { $0.starts(with: "x-cos-meta-") ? String($0.dropFirst(11)) : nil }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url, forKey: .url)
        try container.encode(key, forKey: .key)
        try container.encode(vid, forKey: .vid)
        try container.encode(size, forKey: .size)
        try container.encode(customMeta.mapKeys { "x-cos-meta-" + $0 }, forKey: .meta)

        var metaContainer = container.nestedContainer(keyedBy: MetaCodingKeys.self, forKey: .meta)
        try metaContainer.encodeIfPresent(contentType, forKey: .contentType)
        try metaContainer.encodeIfPresent(cacheControl, forKey: .cacheControl)
        try metaContainer.encodeIfPresent(contentDisposition, forKey: .contentDisposition)
        try metaContainer.encodeIfPresent(contentEncoding, forKey: .contentEncoding)
        try metaContainer.encodeIfPresent(requestId, forKey: .requestId)
        try metaContainer.encodeIfPresent(expireTime, forKey: .expireTime, using: DateCoding.RFC5322.self)
    }
}
