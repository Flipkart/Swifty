//
//  HTTPURLResponse+Headers.swift
//  Swifty
//
//  Created by Suhaas Kumbhajadala on 19/07/23.
//  Copyright © 2023 Swifty. All rights reserved.
//

import Foundation

extension HTTPURLResponse {
    public var caseInsensitiveHTTPHeaders: [String: String] {
        var headers: [String: String] = [:]
        for header in self.allHeaderFields {
            if let fieldName = header.key as? String, let value = self.allHeaderFields[header.key] as? String {
                headers[fieldName.lowercased()] = value
            }
        }
        return headers
    }
}
