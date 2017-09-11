//
//  WebServicePerformanceTests.swift
//  Swifty
//
//  Created by Siddharth Gupta on 10/06/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
import Swifty

class WebServicePerformanceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testHeaderModifierPerformance() {  /* Attaching a header value */
        
        measure {
            let randomNum: UInt32 = arc4random_uniform(100)
            for _ in 1...10000 {
                var resource = NetworkResource(request: URLRequest(url: URL(string: "https://httpbin.org")!))
                resource = resource.header(key: "randomvalue", value: "\(randomNum)")
            }
        }
    }
    
    func testURLRequestGETPerformance() {  /* Creating a simple URLRequest */
        
        measure {
            for _ in 1...10000 {
                var resource = URLRequest(url: URL(string: "https://httpbin.org/get")!)
                resource.httpMethod = "GET"
                
            }
        }
    }
    
}
