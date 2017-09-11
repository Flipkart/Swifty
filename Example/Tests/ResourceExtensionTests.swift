//
//  ResourceExtensionTests.swift
//  Swifty
//
//  Created by Siddharth Gupta on 13/04/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
import Swifty

class ResourceExtensionTests: XCTestCase {
    
    var resource: NetworkResource?
    let baseURL = "https://httpbin.org/get"
    
    
    override func setUp() {
        var request: URLRequest {
            var request = URLRequest(url: URL(string: baseURL)!)
            request.httpMethod = "GET"
            return request
        }
        
        self.resource = NetworkResource(request: request)
    }
    
    
    
    func testQueryMethod() {
        
        let params: Dictionary <String, Any> = ["param": "value", "query": "param", "array": ["1", "2", "3"]]
        let expectedQuery = "array=1,2,3&param=value&query=param"
        
        let builtResource = self.resource!.query(params)
        let readyResource = NetworkResource(request: URLRequest(url: URL(string: "\(baseURL)?\(expectedQuery)")!))
        
        XCTAssertEqual(builtResource.request.url?.absoluteString, readyResource.request.url?.absoluteString)
    }
    
}
