
//
//  FKNetworkRequestTask.swift
//  Pods
//
//  Created by Siddharth Gupta on 28/11/16.
//
//

import Foundation

/// Swifty Network Task
class SwiftyNetworkTask: Task {
    
    /// Network Resource
    public var resource: NetworkResource
    
    /// Session
    internal let session: URLSession
    
    /// Request Interceptors.
    internal let interceptors: [RequestInterceptor]
    
    /// URL Request
    var request: URLRequest {
        return self.resource.request as URLRequest
    }
    
    /// Print's the resource's description
    public var description: String {
        return resource.description
    }
    
    /// Initializes the Swifty Network Task
    ///
    /// - Parameters:
    ///   - resource: NetworkResource
    ///   - session: URLSession
    ///   - interceptors: [RequestInterceptor]
    init(resource: NetworkResource, session: URLSession, interceptors: [RequestInterceptor]) {
        self.resource = resource
        self.session = session
        self.interceptors = interceptors
        super.init()
    }
    
    /// Runs the Swifty Network Task.
    override func run() {
        ///Check for creation errors if any.
        guard self.resource.creationError == nil else {
            ///There is a creation error. Therfore finish the current task.
            self.finish(with: .error(NetworkResponse(error: self.resource.creationError)))
            return
        }
        /// Intercepts the request with the request interceptors defined.
        self.interceptors.forEach { self.resource = $0.intercept(resource: self.resource) }
        /// Creates a Data Task
        let dataTask = session.dataTask(with: self.request, completionHandler: { (data, response, error) in
            if let networkError = error {
                self.finish(with: .error(NetworkResponse(error: networkError as NSError)))
            }
            else if let response = response as? HTTPURLResponse, let data = data {
                self.finish(with: .success(NetworkResponse(response: response, data: data, parser: self.resource.parser)))
            }
        })
        /// Runs the data task.
        dataTask.resume()
    }
}
