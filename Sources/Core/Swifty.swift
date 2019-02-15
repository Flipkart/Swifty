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

/// Swifty Success Block
public typealias SwiftySuccessBlock = (NetworkResponse) -> Void

/// Swifty Failure Block
public typealias SwiftyFailureBlock = (NetworkResponse) -> Void

struct SwiftyInterceptors {
    static let requestInterceptors: [RequestInterceptor] = [MultiPartEncodingInterceptor()]
    static let responseInteptors: [ResponseInterceptor] = [ValidationInterceptor(), SwiftyParsingInterceptor()]
}

/// Swifty: The main entry point to the networking infrastructure. Keeps track of the constraints and interceptors and services the requests with it's URLSession while taking care of all the attributes of the network resource.
@objc final public class Swifty: NSObject {
    
    /// Swifty's shared instance: It's highly recommended you create your own Swifty instances with your customizations (Constraints, Interceptors) instead of using the shared instance.
    @objc public static let shared = Swifty()
    
    /// The URLSession of this Swifty instance
    let session: URLSession
    
    /// Request Interceptors: Array of the user provided request interceptors which will be executed in order on a background thread.
    let requestInterceptors: [RequestInterceptor]
    
    /// Response Interceptors: Array of the user provided response interceptors which will be executed in order on a background thread.
    let responseInterceptors: [ResponseInterceptor]
    
    /// Constraints: Array of Constaints which can make requests wait until they are satisfied.
    let constraints: [Constraint]
    
    /// Concurrent Network Queue having a utility QOS.
    let networkQueue = DispatchQueue(label: "swifty.networkOperations", qos: .utility, attributes: [.concurrent])
    
    /// Initialize Swifty with the given URLSession, Constraints, and Request & Response Interceptors
    ///
    /// The constraints and interceptors passed in these arguments will run in same order as passed in these arrays.
    ///
    /// - Parameters:
    ///   - session: URLSession
    ///   - constraints: Array of Constraints.
    ///   - requestInterceptors: Array of Request Interceptors.
    ///   - responseInterceptors: Array of Response Interceptors.
    public init(session: URLSession,
                constraints: [Constraint] = [],
                requestInterceptors: [RequestInterceptor] = [],
                responseInterceptors: [ResponseInterceptor] = []) {
        self.session = session
        self.constraints = constraints
        self.requestInterceptors = SwiftyInterceptors.requestInterceptors + requestInterceptors
        self.responseInterceptors = SwiftyInterceptors.responseInteptors + responseInterceptors
        super.init()
    }
    
    /// Initialize Swifty with the given URLSessionConfiguration, Constraints, Request Interceptors & Response Interceptors
    ///
    /// The constraints and interceptors passed in these arguments will run in same order as passed in these arrays.
    ///
    /// - Parameters:
    ///   - configuration: URLSessionConfiguration (Defaults to URLSessionConfiguration.default)
    ///   - constraints: Array of Constraints.
    ///   - requestInterceptors: Array of Request Interceptors.
    ///   - responseInterceptors: Array of Response Interceptors.
    public convenience init(configuration: URLSessionConfiguration = URLSessionConfiguration.default,
                            constraints: [Constraint] = [],
                            requestInterceptors: [RequestInterceptor] = [],
                            responseInterceptors: [ResponseInterceptor] = [],
                            sessionMetricsDelegate: URLSessionTaskDelegate? = nil) {
        
        #if DEBUG
            let session = URLSession(configuration: configuration, delegate: sessionMetricsDelegate ?? SwiftyURLSessionDelegate.shared, delegateQueue: nil)
        #else
            let session = URLSession(configuration: configuration, delegate: sessionMetricsDelegate, delegateQueue: nil)
        #endif
        
        self.init(session: session, constraints: constraints, requestInterceptors: requestInterceptors, responseInterceptors: responseInterceptors)
    }
    
    /// Adds a network resource to run on the Swifty Queue.
    ///
    /// This is what is called internally when you use .load() method or any variant of the .load() method on a NetworkResource
    ///
    /// - Parameters:
    ///   - resource: NetworkResource
    ///   - successBlock: SwiftySuccessBlock
    ///   - failureBlock: SwiftyFailureBlock
    @objc public func add(_ resource: NetworkResource, successBlock: @escaping SwiftySuccessBlock, failureBlock: @escaping SwiftyFailureBlock){
        let task = SwiftyNetworkTask(resource: resource, session: session, interceptors: self.requestInterceptors)
        // Swifty Enters the group
        task.group.enter()
        // Evaluate Conditions
        if(resource.canHaveConstraints){
            constraints.forEach { (conditionManager) in
                task.group.enter()
                conditionManager.satisfy(for: task, on: self.networkQueue)
            }
        }
        
        task.onValue { (networkResponse) in
            let interceptedResponse = self.responseInterceptors.reduce(networkResponse, { $1.intercept(response: $0) })
            successBlock(interceptedResponse)
        }
        
        task.onError { (networkResponse) in
            let interceptedResponse = self.responseInterceptors.reduce(networkResponse, { $1.intercept(response: $0) })
            failureBlock(interceptedResponse)
        }
        // Task starts on the network queue.
        task.start(on: networkQueue)
        // Swifty Exits the group to let the task begin, provided all constraints satisfied
        task.group.leave()
    }
    
    ///Cancelling and invalidating the session.
    deinit {
        session.invalidateAndCancel()
    }
}

// MARK: - WebServiceNetworkInterface.
extension Swifty: WebServiceNetworkInterface {
    /// Conforms Swifty's shared instance to the WebServiceNetworkInterface protocol, making it easy to use directly with a WebService.
    @objc public func loadResource(resource: NetworkResource, completion: @escaping (NetworkResponse) -> Void) {
        self.add(resource, successBlock: { (networkResponse) in
            completion(networkResponse)
        }, failureBlock: { (networkResponse) in
            completion(networkResponse)
        })
    }
}

