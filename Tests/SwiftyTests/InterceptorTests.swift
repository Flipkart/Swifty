//
//  InterceptorTests.swift
//  Swifty
//
//  Created by Siddharth Gupta on 26/03/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import Swifty
import XCTest

public class NetworkInterface: WebServiceNetworkInterface {
    
    let swifty: Swifty
    
    public init(requestInterceptors: [RequestInterceptor] = [], responseInterceptors: [ResponseInterceptor] = [], constraints: [Constraint] = []) {
        self.swifty = Swifty(constraints: constraints, requestInterceptors: requestInterceptors, responseInterceptors: responseInterceptors)
    }
    
    public func loadResource(resource: NetworkResource, completion: @escaping (NetworkResponse) -> Void) {
        self.swifty.add(resource, successBlock: { (response) in
            completion(response)
        }) { (response) in
            completion(response)
        }
    }
}

class InterceptorTests: XCTestCase {
    
    var request: URLRequest {
        var request = URLRequest(url: URL(string: "https://httpbin.org/get")!)
        request.httpMethod = "GET"
        return request
    }
    
    func testSimpleRequestInterceptor() {
        
        let taskFinished = self.expectation(description: "Single Request Interceptor")
        
        let key = "Simple"
        let value = "Value"
        
        let interceptors = [SimpleRequestInterceptor(freshHeader: [key: value])]
        let interface = NetworkInterface(requestInterceptors: interceptors)
        
        let resource = NetworkResource(request: request as! NSMutableURLRequest, networkInterface: interface)
        
        resource.loadJSON(successBlock: { (response) in
            if let data = response as? Dictionary<AnyHashable, Any> {
                if let headers = data["headers"] as? Dictionary<String, String> {
                    XCTAssertNotNil(headers[key], "Looks Like the header from the interceptor was not sent.")
                    XCTAssertEqual(headers[key], value)
                    taskFinished.fulfill()
                }
            }
        }) { (error) in
            print("Error occured in firing the request for test: \(String(describing: error))")
            XCTFail()
        }
        
        self.waitForExpectations(timeout: 5) { error in
            if let error = error {
                print("Test Failed Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testMultipleRequestInterceptors() {
        let gotHeaders = self.expectation(description: "Multiple Interceptors: Got Headers")
        let gotQueryParams = self.expectation(description: "Multiple Interceptors: Got Query Params")
        
        let key = "Simple"
        let value = "Value"
        
        let interceptors: [RequestInterceptor] = [SimpleRequestInterceptor(freshHeader: [key: value]), QueryParamsAddingInterceptor(queryParams: [key: value])]
        let interface = NetworkInterface(requestInterceptors: interceptors)
        let resource = NetworkResource(request: request as! NSMutableURLRequest, networkInterface: interface)
        
        resource.loadJSON(successBlock: { (response) in
            if let data = response as? Dictionary<AnyHashable, Any> {
                if let headers = data["headers"] as? Dictionary<String, String> {
                    XCTAssertNotNil(headers[key], "The header from the interceptor was not sent.")
                    XCTAssertEqual(headers[key], value)
                    gotHeaders.fulfill()
                }
                if let args = data["args"] as? Dictionary<String, String> {
                    XCTAssertNotNil(args[key], "The query params from the interceptor was not sent.")
                    XCTAssertEqual(args[key], value)
                    gotQueryParams.fulfill()
                }
            }
        }) { (error) in
            print("Error occured in firing the request for test: \(String(describing: error))")
            XCTFail()
        }
        
        self.waitForExpectations(timeout: 5) { error in
            if let error = error {
                print("Test Failed Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testSimpleResponseInterceptor() {
        
        let taskFinished = self.expectation(description: "Single Response Interceptor")
        
        let interceptors = [ForceFailing204ResponseInterceptor()]
        let interface = NetworkInterface(responseInterceptors: interceptors)
        
        let request = URLRequest(url: URL(string: "https://httpbin.org/status/204")!)
        let resource = NetworkResource(request: request as! NSMutableURLRequest, networkInterface: interface)
        
        resource.loadJSON(successBlock: { (response) in
            XCTFail("Response did not pass the interceptor, or the interceptor did not work as intended.")
        }) { (error) in
            XCTAssertNotNil(error)
            XCTAssertEqual(error.domain, ForceFailing204ResponseInterceptor.domain)
            taskFinished.fulfill()
        }
        
        self.waitForExpectations(timeout: 5) { error in
            if let error = error {
                print("Test Failed Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testMultipleResponseInterceptors() {
        
        let taskFinished = self.expectation(description: "Multiple Response Interceptors")
        
        let interceptors: [ResponseInterceptor] = [ForceFailing204ResponseInterceptor(), ForceSucceedingResponseInterceptor()]
        let interface = NetworkInterface(responseInterceptors: interceptors)
        
        let request = URLRequest(url: URL(string: "https://httpbin.org/status/204")!)
        let resource = NetworkResource(request: request as! NSMutableURLRequest, networkInterface: interface)
        
        resource.load { (networkResponse) in
            
            guard (networkResponse.error == nil) else {
                XCTFail()
                return
            }
            
            XCTAssertNil(networkResponse.data) /// Should be an empty body, because of 204
            XCTAssertNotNil(networkResponse.response)
            XCTAssertEqual(networkResponse.response?.statusCode, 204)
            taskFinished.fulfill()
        }
        
        self.waitForExpectations(timeout: 5) { error in
            if let error = error {
                print("Test Failed Error: \(error.localizedDescription)")
            }
        }
    }
}

/// Request Interceptor: Adds the given header to the request
struct SimpleRequestInterceptor: RequestInterceptor {
    let freshHeader: Dictionary<String, String>
    
    func intercept(resource: NetworkResource) -> NetworkResource {
        return resource.headers(freshHeader)
    }
}

/// Request Interceptor: Adds the given query params to the request
struct QueryParamsAddingInterceptor: RequestInterceptor {
    let queryParams: Dictionary<String, String>
    
    func intercept(resource: NetworkResource) -> NetworkResource {
        return resource.query(queryParams)
    }
}

/// Response Interceptor: Force fails all HTTP Status Code 204 Responses
struct ForceFailing204ResponseInterceptor: ResponseInterceptor {
    
    static let domain = "ForceFailedInterceptorErrorDomain"
    
    func intercept(response: NetworkResponse) -> NetworkResponse {
        if let httpResponse = response.response, httpResponse.statusCode == 204 {
            response.fail(error: NSError(domain: ForceFailing204ResponseInterceptor.domain, code: 0, userInfo: nil))
        }
        
        return response
    }
}

/// Response Interceptor: Force succeeds all responses with an Error Domain equal to: ForceFailedInterceptorErrorDomain
struct ForceSucceedingResponseInterceptor: ResponseInterceptor {
    
    func intercept(response: NetworkResponse) -> NetworkResponse {
        
        if let error = response.error, error.domain == ForceFailing204ResponseInterceptor.domain {
            response.succeed(response: response.response, data: response.data)
        }
        return response
    }
}



