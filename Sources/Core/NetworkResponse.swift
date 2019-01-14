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


/// The protocol for creating a Response Parser
public protocol ResponseParser {
    /**
     Custom Response parser need to implement this method. When done deserializing the NetworkResponse's data, they have to set it to the NetworkResponse's result variable. 
     
     Any error thrown here while parsing will fail the NetworkResponse, and call the failure block with the thrown error.
    */
    func parse(response: NetworkResponse) throws
}

/// The NetworkResponse class contains the Data, URLResponse, Error (if any) and possibly the serialized response for a given resource.
@objc public class NetworkResponse: NSObject {

// MARK: - Properties
    
    /// The HTTPURLResponse receieved from the network
     @objc public var response : HTTPURLResponse?
    
    /// The raw Data receieved from the network
     @objc public var data: Data?
    
    /// Error that response encountered (if any)
     @objc public var error: NSError?
    
    /// The result of the response serialization
     @objc public var result: Any?
    
    /// The ResponseParser that Swifty should use to serialize this repsonse
    public var parser: ResponseParser?
    
// MARK: - Initializers
    
    /// Initializes the network response
    ///
    /// - Parameters:
    ///   - response: HTTPURLResponse?
    ///   - data: Data?
    ///   - error: NSError?
    ///   - parser: ResponseParser?
    public init(response: HTTPURLResponse? = nil, data: Data? = nil, error: NSError? = nil, parser: ResponseParser? = nil){
        self.response = response
        self.data = data
        self.error = error
        self.parser = parser
    }
    
// MARK: - Modifiers
    
    /// Forcefully succeeds the response, with the given response and data. This internally sets the error to nil. This is especially useful in response interceptors.
    ///
    /// - Parameters:
    ///   - response: HTTPURLResponse?
    ///   - data: Data?
    @objc public func succeed(response: HTTPURLResponse?, data: Data?){
        self.response = response
        self.data = data
        self.error = nil
    }
    
    
    /// Forcefully fails the response, with the given error. This is especially useful in response interceptors.
    ///
    /// - Parameter error: NSError.
    @objc public func fail(error: NSError){
        self.error = error
    }
}
