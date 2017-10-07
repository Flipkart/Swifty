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

/**
 Request Interceptors are called just before a request is about to fire over the network. Request Interceptors are called **after** all the constraints of a request a satisfied, but just **before** a request is about to go over the network. This makes them especially useful to add parameters to the requests they need to succeed.
 
 Your interceptors are always called **in the order** they are passed into the Swifty Initializer. Also, each interceptor's result is then sent into the next one, that is, the interceptors are **executed serially**.
 
 > You should not do too much work synchronously in your request interceptors, since your requests have to wait for the interceptors before firing over the network. If you need to do long running tasks before requests, try using a `Constraint` instead.
 
 To create a `RequestInterceptor`, simply create a class/struct that conforms to the `RequestInterceptor` protocol, and implement the one required method: `intercept(resource: NetworkResource)`
 
 */
public protocol RequestInterceptor {
    /**
     This method gives you the chance to modify the network resource just before it fires over the network.
     
     You can use all the same modifiers here like `.header()` or `.query()` as you can use in the WebService.
     
     **Special Case:**
     - If you want to modify the body of the network resource here, you need to cast the given resource into a NetworkResourceWithBody first before you use those method:
     
     ~~~swift
     class BodyModifyingInterceptor: RequestInterceptor {
     
     func intercept(resource: NetworkResource) -> NetworkResource {
     
         // Cast the NetworkResource into the more specialized type NetworkResourceWithBody
         if let resource = resource as? NetworkResourceWithBody {
            // You can use the body encoding methods here like `.json()` or `.data()`
         }
     
        return resource
     }
     ~~~
     
     - Parameter resource: NetworkResource
     - Returns: NetworkResource
    */
    func intercept(resource: NetworkResource) -> NetworkResource
}

/**
 Response Interceptors are called just before a response is going to be returned back to the caller.
 
 > Examples of things you can do here:
 
 > - Collect/Log statistics about the failure rate of responses by counting the number of errors
 > - Update your session information from every response, if they have any
 > - You can even force ```succeed``` or force ```fail``` your responses in Response Interceptors
 
You should not do too much work synchronously in your response interceptors, since your responses have to wait for the interceptors before reaching back the caller. If you have to do long running tasks here, try dispatching them instead of running them synchronously, so that at least the `intercept` method returns quickly.
 
 */
public protocol ResponseInterceptor {
    /**
     This method gives you the chance to modify the network response just before it returns back to the original caller.
     
     **Special Modifiers:**
     - You can force `fail` or force `succeed` a response here using the methods `.fail()` or `.succeed()` on NetworkResponse
     
     - Parameter response: NetworkResponse
     - Returns: NetworkResponse
     */
    func intercept(response: NetworkResponse) -> NetworkResponse
}
