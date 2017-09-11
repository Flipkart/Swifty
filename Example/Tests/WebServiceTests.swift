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

class AppWebService: WebService {
    static var serverURL = "https://httpbin.org"
    static var networkInterface: WebServiceNetworkInterface = Swifty.shared
    
    static func getAwesomeData(for user: String) -> NetworkResource {
        return server.get("get").query(["user": user])
    }
    
    static func customRequest(base: String, path: String) -> NetworkResource {
        return customResource(with: base).get(path)
    }
}

class WebServiceTests: XCTestCase {
    
    func testURLCreationWithModifier(){
        let url = AppWebService.getAwesomeData(for: "John").request.url?.absoluteString
        XCTAssert((url == "https://httpbin.org/get?user=John"), "The URL created by the GET modifier seems to be invalid")
    }
    
    func testCustomResource(){
        let url = AppWebService.customRequest(base: "https://example.com", path: "path").request.url?.absoluteString
        XCTAssert((url == "https://example.com/path"), "The URL created by the GET modifier seems to be invalid")
    }
    
    
    
}
