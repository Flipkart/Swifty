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


/// WebServiceNetworkInterface: A protocol which lets any object become a bridge between a webservice and the internet. Instances of Swifty conform to this protocol by default
///
/// Conformance to this only requires the implementation of one method: loadResource(resource: completion:)
@objc public protocol WebServiceNetworkInterface: class {
    
    /// Implement this method to tell a WebService what to do when .load() is called on it's NetworkResource. The NetworkResource on which the .load() method is called comes in as an argument, and any networking library can be used to fire the resource's internal request over the network, create a NetworkResponse from the actual response, and passed into the completion closure.
    ///
    /// - Parameters:
    ///   - resource: NetworkResource
    ///   - completion: The completion block which expects a NetworkResponse for the resource that was passed in.
    func loadResource(resource: NetworkResource, completion: @escaping (NetworkResponse) -> Void)
}

/// WebService is a protocol which helps you write your network requests in a declarative, type-safe and expressive way.
///
/// You start by creating a class, putting in your server's **base URL** & a **network interface**, and begin writing your **network requests as functions**
@objc public protocol WebService {
    
    /**
     The Base URL of the server. Needs to have a `scheme (http/https)`, and a URL.
     
     Example: https://example.com
     
     A trailing forward slash in **not required** at the end of the URL.
    */
    static var serverURL: String { get set }
    
    /// The network interface this WebService will use to communicate with the network.
    ///
    /// > This is usually a class conforming to the `WebServiceNetworkInterface` protocol, holding an instance of `Swifty` with your custom `Interceptors` and `Constraints`.
    static var networkInterface: WebServiceNetworkInterface { get set }
}

extension WebService {
    
    /// A BaseResource created from the server URL of the WebService
    ///
    /// Use this as the starting point while creating requests in your WebService.
    static public var server: BaseResource {
        if let url = URL(string: serverURL) {
            return BaseResource(request: NSMutableURLRequest(url: url), networkInterface: networkInterface)
        }
        return BaseResource(predisposition: WebServiceError.invalidBaseURL(url: "Your WebService \(self) has an Invalid Server Base URL | Please make sure you specifiy a scheme (http/https) and a valid path with URL Allowed Characters, a trailing slash is not required."))
    }
    
    /// Can be used to have a custom base URL for a request, instead of the using the WebService's Server URL
    ///
    /// - Parameter baseURL: String
    /// - Returns: BaseResource
    static public func customResource(with baseURL: String) -> BaseResource {
        if let customURL = URL(string: baseURL) {
            let request = NSMutableURLRequest(url: customURL)
            return BaseResource(request: request, networkInterface: networkInterface)
        }
        return BaseResource(predisposition: WebServiceError.invalidBaseURL(url: "Invalid URL passed into custom resource | Please make sure you specifiy a scheme (http/https) and a valid path with URL Allowed Characters, a trailing slash is not required."))
    }
    
}

