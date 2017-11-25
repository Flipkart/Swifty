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
    static var networkInterface: WebServiceNetworkInterface = Swifty()
    
    static func getAwesomeData(for user: String) -> NetworkResource {
        return server.get("get").query(["user": user])
    }
    
    static func customRequest(base: String, path: String) -> NetworkResource {
        return customResource(with: base).get(path)
    }
    
    static func hiddenHTTPAuth(user: String, password: String) -> NetworkResource {
        return server.get("hidden-basic-auth/\(user)/\(password)").authorizationHeader(username: user, password: password)
    }
    
    static func getRequest() -> NetworkResource {
        return server.get("get")
    }
    
    static func postRequest() -> NetworkResourceWithBody {
        return server.post("post")
    }
    
    static func getIP() -> NetworkResource {
        return server.get("ip")
    }
    
    static func get(statusCode: Int) -> NetworkResource {
        return server.get("/status/\(statusCode)")
    }
    
    static func baseResource() -> BaseResource {
        return server
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
    
    func testMethodModifiers() {
        
        let getResource = TestWebService.baseResource().get("get")
        let postResource = TestWebService.baseResource().post("post")
        let putResource = TestWebService.baseResource().put("put")
        let deleteResource = TestWebService.baseResource().delete("delete")
        
        XCTAssertNotNil(getResource)
        XCTAssertNotNil(postResource)
        XCTAssertNotNil(putResource)
        XCTAssertNotNil(deleteResource)
        
        XCTAssertEqual(getResource.request.url?.absoluteString, "https://httpbin.org/get")
        XCTAssertEqual(getResource.request.httpMethod, "GET")
        XCTAssertEqual(postResource.request.url?.absoluteString, "https://httpbin.org/post")
        XCTAssertEqual(postResource.request.httpMethod, "POST")
        XCTAssertEqual(putResource.request.url?.absoluteString, "https://httpbin.org/put")
        XCTAssertEqual(putResource.request.httpMethod, "PUT")
        XCTAssertEqual(deleteResource.request.url?.absoluteString, "https://httpbin.org/delete")
        XCTAssertEqual(deleteResource.request.httpMethod, "DELETE")
    }
    
    func testHeaderModifier() {
        
        let key = "HeaderKey"
        let value = "HeaderValue"
        let resource = TestWebService.getRequest().header(key: key, value: value)
        let bodyResource = TestWebService.postRequest().header(key: key, value: value)
        
        XCTAssertNotNil(resource)
        XCTAssertEqual(resource.request.allHTTPHeaderFields!, [key: value])
        XCTAssertNotNil(bodyResource)
        XCTAssertEqual(bodyResource.request.allHTTPHeaderFields!, [key: value])
    }
    
    func testHeadersModifier() {
        
        let headers = ["Header1": "Value1", "Header2": "Value2"]
        let resource = TestWebService.getRequest().headers(headers)
        let bodyResource = TestWebService.postRequest().headers(headers)
        
        XCTAssertNotNil(resource)
        XCTAssertEqual(resource.request.allHTTPHeaderFields!, headers)
        XCTAssertNotNil(bodyResource)
        XCTAssertEqual(bodyResource.request.allHTTPHeaderFields!, headers)
    }
    
    func testQueryModifier() {
        let key = "QueryKey"
        let value = "QueryValue"
        let resource = TestWebService.getRequest().query([key: value])
        let bodyResource = TestWebService.postRequest().query([key: value])
        
        XCTAssertNotNil(resource)
        XCTAssertEqual(resource.request.url?.absoluteString, "https://httpbin.org/get?\(key)=\(value)")
        XCTAssertNotNil(bodyResource)
        XCTAssertEqual(bodyResource.request.url?.absoluteString, "https://httpbin.org/post?\(key)=\(value)")
    }
    
    func testMultipleQueryModifiers() {
        let key1 = "Query1"
        let value1 = "Val1"
        
        let key2 = "Query2"
        let value2 = "Val2"
        
        let resource = TestWebService.getRequest().query([key1: value1]).query([key2: value2])
        let bodyResource = TestWebService.postRequest().query([key1: value1]).query([key2: value2])
        
        XCTAssertNotNil(resource)
        XCTAssertEqual(resource.request.url?.absoluteString, "https://httpbin.org/get?\(key1)=\(value1)&\(key2)=\(value2)")
        XCTAssertNotNil(bodyResource)
        XCTAssertEqual(bodyResource.request.url?.absoluteString, "https://httpbin.org/post?\(key1)=\(value1)&\(key2)=\(value2)")
    }
    
    func testComplexQueryModifier() {
        let params: Dictionary <String, Any> = ["param": "value", "query": "param", "array": ["1", "2", "3"]]
        let expectedQuery = "array=1,2,3&param=value&query=param"
        
        let resource = TestWebService.getRequest().query(params)
        let bodyResource = TestWebService.postRequest().query(params)
        
        XCTAssertNotNil(resource)
        XCTAssertEqual(resource.request.url?.absoluteString, "https://httpbin.org/get?\(expectedQuery)")
        XCTAssertNotNil(bodyResource)
        XCTAssertEqual(bodyResource.request.url?.absoluteString, "https://httpbin.org/post?\(expectedQuery)")
    }
    
    func testPathWithExistingQueryIsPreserved() {
        let query = "hello=world&count=0"
        let path = "path?\(query)"
        let resource = TestWebService.baseResource().get(path)
        
        XCTAssertNotNil(resource)
        XCTAssertEqual(resource.request.url?.absoluteString, "https://httpbin.org/path?\(query)")
    }
    
    func testJSONEncodingforCodable() {
        
        let person = Person(name: "Programmer", age: 10, languages: ["ObjC", "Swift"])
        let resource = TestWebService.postRequest().json(body: person)
        
        XCTAssertNotNil(resource.request.httpBody)
        XCTAssertEqual(resource.request.allHTTPHeaderFields!["Content-Type"], "application/json")
        
        let decoder = JSONDecoder()
        let decodedPerson = try? decoder.decode(Person.self, from: resource.request.httpBody!)
        
        XCTAssertNotNil(resource)
        XCTAssertNotNil(decodedPerson)
        XCTAssertEqual(decodedPerson?.name, person.name)
        XCTAssertEqual(decodedPerson?.age, person.age)
        XCTAssertEqual(decodedPerson!.languages, person.languages)
    }
    
    func testJSONParser() {
        
        let expectation = self.expectation(description: "Got the IP in response")
        
        TestWebService.getIP().loadJSON(successBlock: { (json) in
            if let json = json as? [String: Any], let _ = json["origin"] as? String {
                expectation.fulfill()
            }
        }) { (error) in
            XCTFail()
        }
        
        self.waitForExpectations(timeout: 4, handler: nil)
    }
    
    func testSimpleError() {
        
        let statusCode = 400
        let expectation = self.expectation(description: "Got the expected Error and Status Code")
        
        TestWebService.get(statusCode: statusCode).loadJSON(successBlock: { (json) in
            
        }) { (error) in
            XCTAssertNotNil(error)
            XCTAssertEqual(error.code, statusCode)
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 4, handler: nil)
    }
    
    func testSucessFor204() {
        
        let statusCode = 204
        let expectation = self.expectation(description: "Got Success for 204 Status code with nil data")
        
        TestWebService.get(statusCode: statusCode).loadJSON(successBlock: { (json) in
            XCTAssertNil(json, "Should Recieve nil data for HTTP Status Code 204")
            expectation.fulfill()
        }) { (error) in
            print(error)
        }
        
        self.waitForExpectations(timeout: 4, handler: nil)
    }
    
}

struct Person: Codable {
    let name: String
    let age: Int
    let languages: [String]
}
