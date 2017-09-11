//
//  NetworkResponse.swift
//  Swifty
//
//  Created by Chirag Ramani on 09/09/17.
//

import Foundation


/// Response Parser
public protocol ResponseParser {
    func parse(response: NetworkResponse) throws
}

/// Network Response
@objc public class NetworkResponse: NSObject {
    /// HTTPURLResponse Response
    public var response : HTTPURLResponse?
    
    /// Response Data
    public var data: Data?
    
    /// Response Error
    public var error: NSError?
    
    /// The parsers set parsing results in this variable
    public var result: Any?
    
    /// Response Parses
    public var parser: ResponseParser?
    
    /// Initializes the network response.
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
    
    /// Forcefully succeeds the response, with the given response and data. This internally sets the error to nil. This is especially useful in response interceptors.
    ///
    /// - Parameters:
    ///   - response: HTTPURLResponse?
    ///   - data: Data?
    public func succeed(response: HTTPURLResponse?, data: Data?){
        self.response = response
        self.data = data
        self.error = nil
    }
    
    
    /// Forcefully fails the response, with the given error. This is especially useful in response interceptors.
    ///
    /// - Parameter error: NSError.
    public func fail(error: NSError){
        self.error = error
    }
}
