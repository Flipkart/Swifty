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

import Foundation


/// Swifty Error Codes
///
public enum SwiftyErrorCodes: Int {
    /// JSON Parsing failure.
    case jsonParsingFailure = 10
    /// Response Validation Error.
    case responseValidation
}

/// WebService Error Codes
///
public enum WebServiceErrorCodes: Int {
    /// Nil Network Interface on Resource.
    case noNetworkInterface
    /// Base URL is empty.
    case emptyBaseURL
    /// Base URL is invalid.
    case invalidBaseURL
    /// URL is empty/invalid.
    case invalidURL
    /// Error while encoding the given fields.
    case fieldsEncodingFailure
    /// URL is invalid after adding query.
    case invalidQueryStringWithURL
    /// Errors while encoding the given JSON.
    case jsonEncodingFailure
    /// Errors while encoding the given type that conforms to the Codable Protocol.
    case codableEncodingFailure
}

/// Errors that can occur in the WebService domain
public class WebServiceError {
    
    /// WebService error domain
    static let errorDomain = "WebServiceErrorDomain"
    
    /// Nil Network Interface on Resource.
    public static func noNetworkInterface() -> NSError {
        return NSError(domain: WebServiceError.errorDomain, code: WebServiceErrorCodes.noNetworkInterface.rawValue, userInfo: self.userInfo(description: "Your network resource doesn't have network interface assigned. If this resource is part of a WebService, please set a valid networkInterface in that WebService"))
    }
    
    ///  Empty Base URL.
    public static func emptyBaseURL() -> NSError {
        return NSError(domain: WebServiceError.errorDomain, code: WebServiceErrorCodes.emptyBaseURL.rawValue, userInfo: self.userInfo(description: "Your network resource has an empty Base URL"))
    }
    
    ///  Invalid Base URL.
    public static func invalidBaseURL(url: String) -> NSError {
        return NSError(domain: WebServiceError.errorDomain, code: WebServiceErrorCodes.invalidBaseURL.rawValue, userInfo: self.userInfo(description: "Invalid baseURL: \(url)"))
    }
    
    ///  Invalid URL.
    public static func invalidURL(url: String) -> NSError {
        return NSError(domain: WebServiceError.errorDomain, code: WebServiceErrorCodes.invalidURL.rawValue, userInfo: self.userInfo(description: "Invalid URL: \(url)"))
    }
    
    /// Invalid URL after adding query params.
    public static func invalidQueryStringWithURL(url: String) -> NSError {
        return NSError(domain: WebServiceError.errorDomain, code: WebServiceErrorCodes.invalidQueryStringWithURL.rawValue, userInfo: self.userInfo(description: "Invalid URL after adding Query String: \(url)"))
    }
    
    /// Fields encoding failure.
    public static func fieldsEncodingFailure(dictionary: [String: Any]) -> NSError {
        return NSError(domain: WebServiceError.errorDomain, code: WebServiceErrorCodes.fieldsEncodingFailure.rawValue, userInfo: self.userInfo(description: "Unable to encode fields to data using .utf8 encoding: \(dictionary)"))
    }
    /// JSON Encoding failure.
    public static func jsonEncodingFailure(dictionary: [AnyHashable: Any], error: Error?) -> NSError {
        return NSError(domain: WebServiceError.errorDomain, code: WebServiceErrorCodes.jsonEncodingFailure.rawValue, userInfo: self.userInfo(description: "Unable to serialize JSON: \(dictionary), due to error: \(String(describing: error?.localizedDescription))"))
    }
    
    /// JSON Array Encoding failure.
    public static func jsonEncodingFailure(array: [Any], error: Error?) -> NSError {
        return NSError(domain: WebServiceError.errorDomain, code: WebServiceErrorCodes.jsonEncodingFailure.rawValue, userInfo: self.userInfo(description: "Unable to serialize JSON Array: \(array), due to error: \(String(describing: error?.localizedDescription))"))
    }
    
    /// Codable Encoding failure.
    public static func codableEncodingFailure(error: Error?) -> NSError {
        return NSError(domain: WebServiceError.errorDomain, code: WebServiceErrorCodes.codableEncodingFailure.rawValue, userInfo: self.userInfo(description: "Unable to JSON Serialize the given Codable type due to error: \(String(describing: error?.localizedDescription))"))
    }
    
    /* User Info Helper */
    static func userInfo(description: String) -> [String: Any] {
        return [NSLocalizedDescriptionKey: description]
    }
}

/// Errors that can occur in the Swifty domain
public class SwiftyError {
    /// Error Domain
    static let errorDomain = "SwiftyErrorDomain"
    
    /// JSON Parsing failure
    public static func jsonParsingFailure(error: Error?) -> NSError {
        return NSError(domain: SwiftyError.errorDomain, code: SwiftyErrorCodes.jsonParsingFailure.rawValue, userInfo: self.userInfo(description: "Unable to deserialize JSON due to error: \(String(describing: error?.localizedDescription))"))
    }
    
    /// Response Validation failure
    public static func responseValidation(reason: String, statusCode: Int = SwiftyErrorCodes.responseValidation.rawValue) -> NSError {
        return NSError(domain: SwiftyError.errorDomain, code: statusCode, userInfo: self.userInfo(description: "Response Validation Failed with reason: \(reason)"))
    }
    
    /* User Info Helper */
    static func userInfo(description: String) -> [String: Any] {
        return [NSLocalizedDescriptionKey: description]
    }
}
