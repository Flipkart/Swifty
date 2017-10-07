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

/// A wrapper over NSMutableURLRequest, it's an alias for a network request in Swifty.
///
/// It provides the chaining modifier syntax and also stores attributes and directions for Swifty to run the given network request.
public class NetworkResource: NSObject {
    
// MARK: - Properties
    
    /// The actual NSMutableURLRequest this resource wraps over
    public let request: NSMutableURLRequest
    
    /// WebServiceNetworkInterface
    weak var networkInterface: WebServiceNetworkInterface?
    
    /// The queue on which the results should be delivered.
    var deliverOn: DispatchQueue = DispatchQueue.main
    
    /// Session priority.
    var priority: URLSessionTaskPriority = .normal
    
    /// Response parser.
    var parser: ResponseParser?
    
    /// Tags allow you to categorize your requests, which helps you to recognize them in your interceptors and constraints to take selective action
    public var tags = Set<String>()
    
    /// Can have constraints.
    var canHaveConstraints = false
    
    /// Creation error
    var creationError: NSError?
    
// MARK: - Initializers
    
    /// Initializes the Network Resource with the given URL, and HTTP Method.
    ///
    /// - Parameters:
    ///   - url: URL
    ///   - method: httpMethod
    public convenience init(url: URL, method: String) {
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = method
        self.init(request: request)
    }
    
    /// Initializes the NetworkResouce with the BaseResource
    ///
    /// - Parameter resource: BaseResource.
    internal convenience init(resource: BaseResource){
        self.init(request: resource.request, networkInterface: resource.networkInterface)
        if let _ = resource.request.url {} else {
            self.creationError = WebServiceError.invalidURL(url: "While Calling Request Method Setters in BaseResource: .get()")
        }
    }
    
    /// Initializes the NetworkResource with the given NSMutableURLRequest
    ///
    /// - Parameters:
    ///   - request: NSMutableURLRequest
    ///   - networkInterface: WebServiceNetworkInterface
    public init(request: NSMutableURLRequest, networkInterface: WebServiceNetworkInterface? = nil) {
        self.request = request
        self.networkInterface = networkInterface
    }
    
    /// Initializes the NetworkResource with the given URLRequest
    ///
    /// - Parameter request: URLRequest.
    public convenience init(request: URLRequest) {
        self.init(request: (request as! NSMutableURLRequest))
    }
    
// MARK: - Utilities
    
    /// The resource's parameters in readable format, including the URL, Headers, Method, and the HTTP Body
    public override var description: String {
        var body = "Empty"
        if let bodyData = self.request.httpBody, let bodyString = String(data: bodyData, encoding: .utf8) {
            body = bodyString
        }
        return "URL: \(self.request.url!)\nMethod: \(self.request.httpMethod)\nHeaders: \(String(describing: self.request.allHTTPHeaderFields))\nBody: \(body)\n\n"
    }
    
    /**
     Prints the resource's parameters in readable format, including the URL, Headers, Method, and the HTTP Body
     */
    @discardableResult
    public func printDetails() -> NetworkResource {
        print(self.description)
        return self
    }
}
