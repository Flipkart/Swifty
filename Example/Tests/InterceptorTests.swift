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

class RequestInterceptorTests: XCTestCase {
    
    var request: URLRequest {
        var request = URLRequest(url: URL(string: "https://httpbin.org/get")!)
        request.httpMethod = "GET"
        return request
    }
    
    func testSimpleHeaderAddingInterceptor() {
        
        let taskFinished = self.expectation(description: "SingleInterceptor")
        
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
    
    
    func testMultipleInterceptors() {
        let gotHeaders = self.expectation(description: "MultipleInterceptors_GotHeaders")
        let gotQueryParams = self.expectation(description: "MultipleInterceptors_GotQueryParams")
        
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
}

struct SimpleRequestInterceptor: RequestInterceptor {
    let freshHeader: Dictionary<String, String>
    
    func intercept(resource: NetworkResource) -> NetworkResource {
        return resource.headers(freshHeader)
    }
}

struct QueryParamsAddingInterceptor: RequestInterceptor {
    let queryParams: Dictionary<String, String>
    
    func intercept(resource: NetworkResource) -> NetworkResource {
        return resource.query(queryParams)
    }
}
