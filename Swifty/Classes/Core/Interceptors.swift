//
//  Interceptors.swift
//  Pods
//
//  Created by Siddharth Gupta on 23/03/17.
//
//

import Foundation

/// Request Interceptor.
public protocol RequestInterceptor {
    /// Modifies the given intermediate network resource.
    ///
    /// - Parameter resource: NetworkResource
    /// - Returns: NetworkResource
    func intercept(resource: NetworkResource) -> NetworkResource
}

/// Response Interceptor.
public protocol ResponseInterceptor {
    /// Modifies the given intermediate network response.
    ///
    /// - Parameter response: NetworkResponse
    /// - Returns: NetworkResponse
    func intercept(response: NetworkResponse) -> NetworkResponse
}
