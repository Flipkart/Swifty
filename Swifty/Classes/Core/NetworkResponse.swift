//
//  NetworkResponse.swift
//  Swifty
//
//  Created by Chirag Ramani on 09/09/17.
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

/// Network Response
@objc public class NetworkResponse: NSObject {
    /// The HTTPURLResponse receieved from the network
    public var response : HTTPURLResponse?
    
    /// The raw Data receieved from the network
    public var data: Data?
    
    /// Error that response encountered (if any)
    public var error: NSError?
    
    /// The result of the response serialization
    public var result: Any?
    
    /// The ResponseParser that Swifty should use to serialize this repsonse
    public var parser: ResponseParser?
    
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
