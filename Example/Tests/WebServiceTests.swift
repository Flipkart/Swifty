//
//  WebServiceTests.swift
//  Swifty
//
//  Created by Siddharth Gupta on 01/05/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
import Swifty

class TestWebService: WebService {
    static var serverURL = "https://httpbin.org"
    static var networkInterface: WebServiceNetworkInterface = Swifty.shared
    
    static func getAwesomeData(for user: String) -> NetworkResource {
        return server.get("get").query(["user": user])
    }
    
    static func customRequest(base: String, path: String) -> NetworkResource {
        return customResource(with: base).get(path)
    }
    
    static func hiddenHTTPAuth(user: String, password: String) -> NetworkResource {
        return server.get("hidden-basic-auth/\(user)/\(password)").authorizationHeader(username: user, password: password)
    }
}

class WebServiceTests: XCTestCase {
    
    func testURLCreationWithModifier(){
        let url = TestWebService.getAwesomeData(for: "John").request.url?.absoluteString
        XCTAssert((url == "https://httpbin.org/get?user=John"), "The URL created by the GET modifier seems to be invalid")
    }
    
    func testCustomResource(){
        let url = TestWebService.customRequest(base: "https://example.com", path: "path").request.url?.absoluteString
        XCTAssert((url == "https://example.com/path"), "The URL created by the GET modifier seems to be invalid")
    }
    
    func testHiddenHTTPBasicAuthorization() {
        
        let expectation = self.expectation(description: "HTTP Basic Auth Should Succeed with Status Code 200")
        
        TestWebService.hiddenHTTPAuth(user: "user", password: "passwd").load { (networkResponse) in
            guard networkResponse.error == nil else {
                XCTFail()
                return
            }
            
            if let response = networkResponse.response, response.statusCode == 200 {
                expectation.fulfill()
            }
        }
        
        self.waitForExpectations(timeout: 6, handler: nil)
    }
    
    func testHiddenHTTPBasicAuthorizationWithInvalidCredentials() {
        
        let expectation = self.expectation(description: "HTTP Basic Auth Should Succeed with Status Code 200")
        
        TestWebService.hiddenHTTPAuth(user: "user", password: "passwd").authorizationHeader(username: "Invalid", password: "Credentials").load { (networkResponse) in
            
            guard let httpResponse = networkResponse.response else {
                XCTFail()
                return
            }
            
            if httpResponse.statusCode == 404 {
                XCTAssertNotNil(networkResponse.error)
                expectation.fulfill()
            }
        }
        
        self.waitForExpectations(timeout: 6, handler: nil)
    }
    
    
    
}
