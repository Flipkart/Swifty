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
@objc public class NetworkResource: NSObject {
    
// MARK: - Properties
    
    /// The actual NSMutableURLRequest this resource wraps over
     @objc public let request: NSMutableURLRequest
    
    /// WebServiceNetworkInterface
    weak var networkInterface: WebServiceNetworkInterface?
    
    /// The queue on which the results should be delivered.
    var deliverOn: DispatchQueue = DispatchQueue.main
    
    /// Session priority.
    var priority: URLSessionTaskPriority = .normal
    
    /// Response parser.
    var parser: ResponseParser?
    
    /// Tags allow you to categorize your requests, which helps you to recognize them in your interceptors and constraints to take selective action
     @objc public var tags = Set<String>()
    
    /// Can have constraints
    var canHaveConstraints = false
    
    /// Mocked Data for the resource. Set using the `.mock()` modifier
    var mockedData: Data?
    
    var multipartData: [BodyPart]?
    
    /// Error (if any) encountered while Webservice was creating this request.
    ///
    /// Set this error in your own extensions of `NetworkResource` or `NetworkResourceWithBody` Modifiers to inform callers of errors that fail the request, for example, JSON encoding failures.
    ///
    /// If this not `nil` at the time the `load` method on this request is called, the request will **automatically fail** with this error without ever hitting the network.
     @objc public var creationError: NSError?
    
// MARK: - Initializers
    
    /// Initializes the NetworkResource with the given URL, and HTTP Method.
    ///
    /// - Parameters:
    ///   - url: URL
    ///   - method: httpMethod
    @objc public convenience init(url: URL, method: String) {
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = method
        self.init(request: request)
    }
    
    /// Initializes the NetworkResource with the BaseResource
    ///
    /// - Parameter resource: BaseResource.
    internal convenience init(resource: BaseResource) {
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
    @objc public init(request: NSMutableURLRequest, networkInterface: WebServiceNetworkInterface? = nil) {
        self.request = request
        self.networkInterface = networkInterface
    }
    
    /// Initializes the NetworkResource with the given URLRequest
    ///
    /// - Parameter request: URLRequest.
    @objc public convenience init(request: URLRequest) {
        self.init(request: (request as! NSMutableURLRequest))
    }
    
// MARK: - Utilities
    
    /// The resource's parameters in readable format, including the URL, Headers, Method, and the HTTP Body
    public override var description: String {
        var body = "Empty"
        if let bodyData = self.request.httpBody, bodyData.count > 0 {
            body = "\(bodyData.count) bytes"
            if let bodyString = String(data: bodyData, encoding: .utf8) {
                body += "\n\(bodyString)"
            }
        }
        return "URL: \(self.request.url!)\nMethod: \(self.request.httpMethod)\nHeaders: \(String(describing: self.request.allHTTPHeaderFields))\nBody: \(body)\n\n"
    }
    
    /**
     Prints the resource's parameters in readable format, including the URL, Headers, Method, and the HTTP Body
     */
    @discardableResult
    @objc public func printDetails() -> NetworkResource {
        print(self.description)
        return self
    }
}
