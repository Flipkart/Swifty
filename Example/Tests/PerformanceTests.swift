import UIKit
import XCTest
import Swifty
import Alamofire

class PerformanceTests: XCTestCase {
    
    
    var GETRequest : URLRequest {
        let randomNum: UInt32 = arc4random_uniform(100)
        var request = URLRequest(url: URL(string: "https://httpbin.org/get?number=\(randomNum)")!)
        request.httpMethod = "GET"
        return request
    }
    var POSTRequest : URLRequest {
        var request = URLRequest(url: URL(string: "https://httpbin.org/post")!)
        let data = try! JSONSerialization.data(withJSONObject: ["Hello" : "World"], options: [])
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["Headers": "World"]
        request.httpBody = data
        return request
    }
    
    var manager : Swifty? = Swifty.shared
    var session : URLSession? = URLSession(configuration: URLSessionConfiguration.ephemeral)
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testGET() {
        
        measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: true) {
            let expec = self.expectation(description: "GET")
            
            self.manager!.add(NetworkResource(request: self.GETRequest), successBlock: { (networkResponse) in
                
                expec.fulfill()
            }, failureBlock: { (networkResponse) in
                expec.fulfill()
            })
            
            self.waitForExpectations(timeout: 5) { error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
                self.stopMeasuring()
            }
        }
    }

    func testPOST() {
        
        measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: true) {
            let expec = self.expectation(description: "POST")
            
            self.manager!.add(NetworkResource(request: self.POSTRequest), successBlock: { (networkResponse) in
                expec.fulfill()
            }, failureBlock: { (networkResponse) in
                expec.fulfill()
            })
            
            self.waitForExpectations(timeout: 5) { error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
                self.stopMeasuring()
            }
        }
    }
    
    func testGET_URLSession() {
        
        measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: true) {
            let expec = self.expectation(description: "nGET")
            
            self.session?.dataTask(with: self.GETRequest, completionHandler: { (data, response, error) in
                guard (error == nil) else { print("GET using URLSession Failed"); return }
                expec.fulfill()
            }).resume()
            
            self.waitForExpectations(timeout: 5) { error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
                self.stopMeasuring()
            }
        }
    }
    
    func testPOST_URLSession() {
        
        measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: true) {
            let expec = self.expectation(description: "nPOST")
            
            self.session?.dataTask(with: self.POSTRequest, completionHandler: { (data, response, error) in
                guard (error == nil) else { print("POST using URLSession Failed"); return }
                expec.fulfill()
            }).resume()
            
            self.waitForExpectations(timeout: 5) { error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
                self.stopMeasuring()
            }
        }
    }

    func testGET_Alamofire() {
        
        measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: true) {
            let expec = self.expectation(description: "aGET")
            
            Alamofire.request(self.GETRequest).responseJSON { response in
                if let _ = response.result.value {
                    expec.fulfill()
                }
            }
            
            self.waitForExpectations(timeout: 5) { error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
                self.stopMeasuring()
            }
        }
    }
    
    func testPOST_Alamofire() {
        
        measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: true) {
            let expec = self.expectation(description: "aPOST")
            
            Alamofire.request(self.POSTRequest).responseJSON { response in
                if let _ = response.result.value {
                    expec.fulfill()
                }
            }
            
            self.waitForExpectations(timeout: 5) { error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
                self.stopMeasuring()
            }
        }
    }
    
}
