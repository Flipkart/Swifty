//
//  RequestBlockingTests.swift
//  Swifty
//
//  Created by Siddharth Gupta on 09/02/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
import Swifty


class ConstraintTests : XCTestCase {
    
    var manager : Swifty?
    var dependencyComplete = false
    
    var request : URLRequest {
        var request = URLRequest.init(url: URL.init(string: "https://httpbin.org/get?request=1")!)
        request.httpMethod = "GET"
        return request
    }
    
    func testSimpleConstraint() {
        
        let taskExpectation = self.expectation(description: "Task Done After Constraint Satisfied")
        
        let constraint = TestConstraint(2)
        let manager = Swifty(constraints: [constraint])
        
        let resource = NetworkResource(request: request)
        resource.canHaveConstraints(true)
        
        if constraint.isConstraintSatisfied(for: resource) {
            XCTFail("Constraint Prematurely Satisfied")
        }
        
        manager.add(resource, successBlock: { (networkResponse) in
            if constraint.isConstraintSatisfied(for: resource) {
                taskExpectation.fulfill()
            }
        }) { (networkResponse) in
            if constraint.isConstraintSatisfied(for: resource){
                taskExpectation.fulfill()
            }
        }
        
        self.waitForExpectations(timeout: 8) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testResourceWaitingOnTwoConstraints() {
        
        let taskExpectation = self.expectation(description: "Task Done After Constraint Satisfied")
        
        let constraints: [Constraint] = [TestConstraint(2), TestConstraint(2)]
        let manager = Swifty(constraints: constraints)
        
        let resource = NetworkResource(request: request)
        resource.canHaveConstraints(true)
        
        for constraint in constraints {
            if constraint.isConstraintSatisfied(for: resource) {
                XCTFail("Constraint Prematurely Satisfied")
            }
        }
        
        manager.add(resource, successBlock: { (networkResponse) in
            for constraint in constraints {
                if !constraint.isConstraintSatisfied(for: resource) {
                    XCTFail("A Constraint was left unsatisfied")
                }
            }
            taskExpectation.fulfill()
        }) { (networkResponse) in
            for constraint in constraints {
                if !constraint.isConstraintSatisfied(for: resource) {
                    XCTFail("A Constraint was left unsatisfied")
                }
            }
            taskExpectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 8) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testConcurrentBlocking() {
        
        let expectation = self.expectation(description: "All tasks completed")
        var taskCount : Int = 2
        let timeout : Double = Double(taskCount) * Double(10)
        
        let manager = Swifty(constraints: [TestConstraint(2), TestConstraint(1), TestConstraint(3)])
        
        DispatchQueue.concurrentPerform(iterations: taskCount) { (i) in
            let resource = NetworkResource(request: self.request)
            resource.canHaveConstraints(true)
            
            manager.add(resource, successBlock: { (networkResponse) in
                print("Request Task Finished")
                taskCount -= 1
                if taskCount == 0 {
                    expectation.fulfill()
                }
            }, failureBlock: { (networkResponse) in
                print("Request Task Finished with Error")
            })
        }
        
        self.waitForExpectations(timeout: timeout) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testMultipleResourcesWaitingForSameConstraint() {
        let expectation = self.expectation(description: "Tasks waited for the long running task")
        let constraint = TestConstraint(3)
        let manager = NetworkInterface(constraints: [constraint])
        
        var taskCount = 5
        
        for _ in 0..<5 {
            let resource = NetworkResource(request: self.request as! NSMutableURLRequest, networkInterface: manager)
            resource.canHaveConstraints(true)
            resource.load(successBlock: { (data) in
                if(constraint.conditionSatisfied){
                    print("Some Task Succeeded & waited for long task to finish")
                    taskCount -= 1
                    if taskCount == 0 {
                        expectation.fulfill()
                    }
                }
                else {
                    XCTFail()
                }
            }, failureBlock: { (error) in
                if(constraint.conditionSatisfied){
                    taskCount -= 1
                    if taskCount == 0 {
                        expectation.fulfill()
                    }
                    print("Some Task Failed, but waited for long task to finish")
                }
                else {
                    XCTFail()
                }
            })
        }
        
        self.waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
        
    }
    
    func testConstraintFailure() {
        let taskExpectation = self.expectation(description: "Task Should Fail with the error it's constraint failed with")
        
        let errorDomain = "SwiftConditionTests"
        
        let constraint = TestConstraint(2, failureError: NSError(domain: errorDomain , code: 1, userInfo: nil))
        let manager = NetworkInterface(constraints: [constraint])
        
        let resource = NetworkResource(request: self.request as! NSMutableURLRequest, networkInterface: manager)
        resource.canHaveConstraints(true)
        
        resource.load(successBlock: { (data) in
            XCTFail()
        }) { (error) in
            if(error.domain == errorDomain){
                taskExpectation.fulfill()
            }
        }
        
        self.waitForExpectations(timeout: 5) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
}

class TestConstraint: Constraint {
    
    public init(_ time: UInt32, failureError: NSError? = nil){
        satisfactionTime = time
        self.failureError = failureError
    }
    
    let satisfactionTime: UInt32
    let failureError: NSError?
    public var conditionSatisfied = false
    
    override func satisfyConstraint(for resource: NetworkResource) {
        sleep(satisfactionTime)
        conditionSatisfied = true
        if let error = self.failureError {
            self.finish(with: error)
        } else {
            self.finish(with: nil)
        }
    }
    
    override func isConstraintSatisfied(for resource: NetworkResource) -> Bool {
        return conditionSatisfied
    }
    
}


