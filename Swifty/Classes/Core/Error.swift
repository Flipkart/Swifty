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
/// - jsonParsingFailure: json parsing failure.
/// - responseValidation: response validatiion error.
public enum SwiftyErrorCodes: Int {
    case jsonParsingFailure = 10
    case responseValidation
}

/// WebServiceErrorCodes
///
/// - emptyBaseURL: Base URL is empty.
/// - invalidBaseURL: Base URL is invalid.
/// - invalidURL: URL is empty.
/// - fieldsEncodingFailure: Errors while encoding fields.
/// - invalidQueryStringWithURL: URL is invalid after adding query.
/// - jsonEncodingFailure: Errors while encoding json.
public enum WebServiceErrorCodes: Int {
    case noNetworkInterface
    case emptyBaseURL
    case invalidBaseURL
    case invalidURL
    case fieldsEncodingFailure
    case invalidQueryStringWithURL
    case jsonEncodingFailure
}

/// WebService error
public class WebServiceError {
    
    /// WebService error domain
    public static let errorDomain = "WebServiceErrorDomain"
    
    /// No Network Interface Error
    public static func noNetworkInterface() -> NSError {
        return NSError(domain: WebServiceError.errorDomain, code: WebServiceErrorCodes.noNetworkInterface.rawValue, userInfo: self.userInfo(description: "Your network resource doesn't have network interface assigned. If this resource is part of a WebService, please set a valid networkInterface in that WebService"))
    }
    
    ///  Empty Base URL NSError.
    public static func emptyBaseURL() -> NSError {
        return NSError(domain: WebServiceError.errorDomain, code: WebServiceErrorCodes.emptyBaseURL.rawValue, userInfo: self.userInfo(description: "Your network resource has an empty Base URL"))
    }
    
    ///  Invalid Base URL NSError.
    public static func invalidBaseURL(url: String) -> NSError {
        return NSError(domain: WebServiceError.errorDomain, code: WebServiceErrorCodes.invalidBaseURL.rawValue, userInfo: self.userInfo(description: "Invalid baseURL: \(url)"))
    }
    
    ///  Invalid URL NSError.
    public static func invalidURL(url: String) -> NSError {
        return NSError(domain: WebServiceError.errorDomain, code:  WebServiceErrorCodes.invalidURL.rawValue, userInfo: self.userInfo(description: "Invalid URL: \(url)"))
    }
    
    /// Invalid URL after adding query params NSError.
    public static func invalidQueryStringWithURL(url: String) -> NSError {
        return NSError(domain: WebServiceError.errorDomain, code:  WebServiceErrorCodes.invalidQueryStringWithURL.rawValue, userInfo: self.userInfo(description: "Invalid URL after adding Query String: \(url)"))
    }
    
    /// Fields encoding failure NSError.
    public static func fieldsEncodingFailure(dictionary: Dictionary<String, Any>) -> NSError {
        return NSError(domain: WebServiceError.errorDomain, code:  WebServiceErrorCodes.fieldsEncodingFailure.rawValue, userInfo: self.userInfo(description: "Unable to encode fields to data using .utf8 encoding: \(dictionary)"))
    }
    /// JSON Encoding failure NSError
    public static func jsonEncodingFailure(dictionary: Dictionary<AnyHashable, Any>, error: Error?) -> NSError {
        return NSError(domain: WebServiceError.errorDomain, code:  WebServiceErrorCodes.jsonEncodingFailure.rawValue, userInfo: self.userInfo(description: "Unable to serialize JSON: \(dictionary), due to error: \(String(describing: error?.localizedDescription))"))
    }
    
    /// JSON Encoding Failure NSError
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
    public static let errorDomain = "SwiftyErrorDomain"
    
    /// JSON Parsing failure NSError
    public static func jsonParsingFailure(error: Error?) -> NSError {
        return NSError(domain: SwiftyError.errorDomain, code:  SwiftyErrorCodes.jsonParsingFailure.rawValue, userInfo: self.userInfo(description: "Unable to deserialize JSON due to error: \(String(describing: error?.localizedDescription))"))
    }
    
    /// Response Validation failure NSError
    public static func responseValidation(reason: String) -> NSError {
        return NSError(domain: SwiftyError.errorDomain, code:  SwiftyErrorCodes.responseValidation.rawValue, userInfo: self.userInfo(description: "Response Validation Failed with reason: \(reason)"))
    }
    
    /* User Info Helper */
    static func userInfo(description: String) -> [AnyHashable : Any] {
        return [NSLocalizedDescriptionKey: description]
    }
}
