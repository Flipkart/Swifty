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

/// A wrapper over NSMutableURLRequest, only containing a request with the Server URL of the WebService
///
/// Use any of the HTTPMethod modifiers like .get() or .post() to get a NetworkResource from this.
@objc public class BaseResource: NSObject {
    
    /// Mutable URL Request
    let request: NSMutableURLRequest
    
    /// The error generated if the serverURL given in a WebService is invalid
    var creationError: NSError?
    
    /// WebServiceNetworkInterface
    weak internal var networkInterface: WebServiceNetworkInterface?
    
    /// Initializes the Base Resource with the given NSMutableURLRequest
    ///
    /// - Parameters:
    ///   - request: NSMutableURLRequest
    ///   - networkInterface: WebServiceNetworkInterface?
    internal init(request: NSMutableURLRequest, networkInterface: WebServiceNetworkInterface? = nil) {
        self.request = request
        self.networkInterface = networkInterface
    }
    
    /// Initializes Base Resource with a creation error.
    ///
    /// - Parameter predisposition: NSError
    internal convenience init(predisposition: NSError) {
        self.init(request: NSMutableURLRequest(url: URL(string: "https://errorLand/")!))
        self.creationError = predisposition
    }
}

public extension BaseResource {
    
// MARK: - Request Modifiers
    
    /// Sets the HTTP Method of the request to GET and returns a NetworkResource.
    ///
    /// The path relative to the server URL should be passed as the argument. The first forward slash is not required.
    /// 
    /// For example: To set path server.com/api, just pass in argument "api"
    ///
    /// - Parameter path: String (The first forward slash is not required)
    /// - Returns: NetworkResource
    func get(_ path: String) -> NetworkResource {
        
        self.request.url?.appendPathComponentPreservingQuery(path: path, isDirectory: false)
        self.request.httpMethod = "GET"
        return NetworkResource(resource: self)
    }
    
    /// Sets the HTTP Method of the request to POST and returns a NetworkResource.
    ///
    /// The path relative to the server URL should be passed as the argument. The first forward slash is not required.
    ///
    /// For example: To set path server.com/api, just pass in argument "api"
    ///
    /// - Parameter path: String (The first forward slash is not required)
    /// - Returns: NetworkResourceWithBody
    func post(_ path: String) -> NetworkResourceWithBody {
        
        self.request.url?.appendPathComponentPreservingQuery(path: path, isDirectory: false)
        self.request.httpMethod = "POST"
        return NetworkResourceWithBody(resource: self)
    }
    
    /// Sets the HTTP Method of the request to PUT and returns a NetworkResource.
    ///
    /// The path relative to the server URL should be passed as the argument. The first forward slash is not required.
    ///
    /// For example: To set path server.com/api, just pass in argument "api"
    ///
    /// - Parameter path: String (The first forward slash is not required)
    /// - Returns: NetworkResourceWithBody
    func put(_ path: String) -> NetworkResourceWithBody {
        
        self.request.url?.appendPathComponentPreservingQuery(path: path, isDirectory: false)
        self.request.httpMethod = "PUT"
        return NetworkResourceWithBody(resource: self)
    }
    
    /// Sets the HTTP Method of the request to DELETE and returns a NetworkResource.
    ///
    /// The path relative to the server URL should be passed as the argument. The first forward slash is not required.
    ///
    /// For example: To set path server.com/api, just pass in argument "api"
    ///
    /// - Parameter path: String (The first forward slash is not required)
    /// - Returns: NetworkResourceWithBody
    func delete(_ path: String) -> NetworkResourceWithBody {
        
        self.request.url?.appendPathComponentPreservingQuery(path: path, isDirectory: false)
        self.request.httpMethod = "DELETE"
        return NetworkResourceWithBody(resource: self)
    }
}

fileprivate extension URL {
    
    mutating func appendPathComponentPreservingQuery(path: String, isDirectory: Bool) {
        
        if(path.contains("?")){
            let split = path.split(separator: "?", maxSplits: 1, omittingEmptySubsequences: true)
            if split.count > 1 {
                let splitPath = String(split[0])
                let splitQuery = String(split[1])
                self.appendPathComponent(splitPath, isDirectory: isDirectory)
                if let url = URL(string: "\(self.absoluteString)?\(splitQuery)") {
                    self = url
                }
                return
            }
        }
        
        self.appendPathComponent(path, isDirectory: isDirectory)
        return
    }
    
}
