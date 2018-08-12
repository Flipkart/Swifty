//
//  MockingTests.swift
//  Swifty_Tests
//
//  Created by Siddharth Gupta on 13/12/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
import Swifty

class MockingTests: XCTestCase {
    
    class TestWebService: WebService {
        
        static var serverURL = "https://httpbin.org"
        static var networkInterface: WebServiceNetworkInterface = Swifty()
        
        static func getIP() -> NetworkResource {
            return server.get("ip")
        }
    }
    
    func testResponseMocking() {
        
        let expectation = self.expectation(description: "Should get mocked response from the file")
        
        TestWebService.getIP().mock(withFile: "mockedResponse").loadJSON(successBlock: { (response) in
            XCTAssertNotNil(response)
            XCTAssert(response is [String: Any])
            if let json = response as? [String: Any], let message = json["message"] as? String {
                XCTAssertEqual(message, "This is the mocked response")
                expectation.fulfill()
            }
        }) { (error) in
            XCTFail()
        }
        
        self.waitForExpectations(timeout: 4, handler: nil)
    }
}




