//
//  Error.swift
//  Pods
//
//  Created by Siddharth Gupta on 5/1/17.
//
//

import Foundation


/// Swifty Error Code
///


public enum SwiftyErrorCodes: Int {
    /// JSON Parsing failure.
    case jsonParsingFailure = 10
    /// Response Validation Error.
    case responseValidation
}

/// WebServiceErrorCodes
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
}

/// WebService error
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
        return NSError(domain: WebServiceError.errorDomain, code:  WebServiceErrorCodes.invalidURL.rawValue, userInfo: self.userInfo(description: "Invalid URL: \(url)"))
    }
    
    /// Invalid URL after adding query params.
    public static func invalidQueryStringWithURL(url: String) -> NSError {
        return NSError(domain: WebServiceError.errorDomain, code:  WebServiceErrorCodes.invalidQueryStringWithURL.rawValue, userInfo: self.userInfo(description: "Invalid URL after adding Query String: \(url)"))
    }
    
    /// Fields encoding failure.
    public static func fieldsEncodingFailure(dictionary: Dictionary<String, Any>) -> NSError {
        return NSError(domain: WebServiceError.errorDomain, code:  WebServiceErrorCodes.fieldsEncodingFailure.rawValue, userInfo: self.userInfo(description: "Unable to encode fields to data using .utf8 encoding: \(dictionary)"))
    }
    /// JSON Encoding failure.
    public static func jsonEncodingFailure(dictionary: Dictionary<AnyHashable, Any>, error: Error?) -> NSError {
        return NSError(domain: WebServiceError.errorDomain, code:  WebServiceErrorCodes.jsonEncodingFailure.rawValue, userInfo: self.userInfo(description: "Unable to serialize JSON: \(dictionary), due to error: \(String(describing: error?.localizedDescription))"))
    }
    
    /// JSON Encoding failure.
    public static func jsonEncodingFailure(array: Array<Any>, error: Error?) -> NSError {
        return NSError(domain: WebServiceError.errorDomain, code:  WebServiceErrorCodes.jsonEncodingFailure.rawValue, userInfo: self.userInfo(description: "Unable to serialize JSON Array: \(array), due to error: \(String(describing: error?.localizedDescription))"))
    }
    
    /* User Info Helper */
    static func userInfo(description: String) -> [AnyHashable : Any] {
        return [NSLocalizedDescriptionKey: description]
    }
}

/// Swifty Error
public class SwiftyError {
    /// Error Domain
    static let errorDomain = "SwiftyErrorDomain"
    
    /// JSON Parsing failure
    public static func jsonParsingFailure(error: Error?) -> NSError {
        return NSError(domain: SwiftyError.errorDomain, code:  SwiftyErrorCodes.jsonParsingFailure.rawValue, userInfo: self.userInfo(description: "Unable to deserialize JSON due to error: \(String(describing: error?.localizedDescription))"))
    }
    
    /// Response Validation failure
    public static func responseValidation(reason: String) -> NSError {
        return NSError(domain: SwiftyError.errorDomain, code:  SwiftyErrorCodes.responseValidation.rawValue, userInfo: self.userInfo(description: "Response Validation Failed with reason: \(reason)"))
    }
    
    /* User Info Helper */
    static func userInfo(description: String) -> [AnyHashable : Any] {
        return [NSLocalizedDescriptionKey: description]
    }
}
