//
//
// Swifty (https://github.com/Flipkart/Swifty)
//
// Copyright 2017 Flipkart Internet Pvt. Ltd.
// Apache License
// Version 2.0, January 2004
//
// See https://github.com/Flipkart/Swifty/blob/master/LICENSE for the full license
//

#if os(iOS)
import UIKit

@available(iOS 10.0, *)
extension URLSessionTaskMetrics.ResourceFetchType {
    /// Display string for the resource fetch type
    var displayString: String {
        switch self {
        case .localCache:
            return "Local Cache"
        case .networkLoad:
            return "Network Load"
        case .serverPush:
            return "Server Push"
        case .unknown:
            return "Unknown"
        @unknown default:
            return "Unknown"
        }
    }
}
@available(iOS 10.0, *)
extension URLSessionTaskTransactionMetrics {
    /// Get the total time it took to connect.
    /// Will be `nil` if `connectStartDate` or `connectEndDate` were `nil`
    var connectTime: TimeInterval? {
        guard let connectEndDate = connectEndDate,
            let connectStartDate = connectStartDate else {
                return nil
        }
        return (connectEndDate.timeIntervalSince1970 - connectStartDate.timeIntervalSince1970) * 1000
    }

    /// Get the total time it took to do the domain lookup.
    /// Will be `nil` if `domainLookupStartDate` or `domainLookupEndDate` were `nil`
    var domainLookupTime: TimeInterval? {
        guard let domainLookupEndDate = domainLookupEndDate,
            let domainLookupStartDate = domainLookupStartDate else {
            return nil
        }
        return (domainLookupEndDate.timeIntervalSince1970 - domainLookupStartDate.timeIntervalSince1970) * 1000
    }

    /// Get the total time it took to do the request.
    /// Will be `nil` if `requestStartDate` or `requestEndDate` were `nil`
    var requestTime: TimeInterval? {
        guard let requestEndDate = requestEndDate,
            let requestStartDate = requestStartDate else {
                return nil
        }
        return (requestEndDate.timeIntervalSince1970 - requestStartDate.timeIntervalSince1970) * 1000
    }

    /// Get the total time it took to get the response.
    /// Will be `nil` if `responseStartDate` or `responseEndDate` were `nil`
    var responseTime: TimeInterval? {
        guard let responseEndDate = responseEndDate,
            let responseStartDate = responseStartDate else {
                return nil
        }
        return (responseEndDate.timeIntervalSince1970 - responseStartDate.timeIntervalSince1970) * 1000
    }

    /// Get the total time it took to create a secure connection.
    /// Will be `nil` if `secureConnectionStartDate` or `secureConnectionEndDate` were `nil`
    var secureConnectionTime: TimeInterval? {
        guard let secureConnectionEndDate = secureConnectionEndDate,
            let secureConnectionStartDate = secureConnectionStartDate else {
                return nil
        }
        return (secureConnectionEndDate.timeIntervalSince1970 - secureConnectionStartDate.timeIntervalSince1970) * 1000
    }
}
#endif
