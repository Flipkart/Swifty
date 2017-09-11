//
//  Task.swift
//  Swifty
//
//  Created by Chirag Ramani on 09/09/17.
//

import Foundation


/// Result of the Task
///
/// - success: for the associated NetworkResponse
/// - error: for the associated NetworkResponse
public enum Result {
    case success(NetworkResponse)
    case error(NetworkResponse)
}


// Task: An abstraction over a GCD work item which offers an asynchronous finish block.
open class Task {
    
    /// Public initializer.
    public init(){ }
    
    /// Dispatch Group: Keeps track of the constraints and lets the task begin when all of the constraints are satisfied.
    let group = DispatchGroup()
    
    /// On value block
    private var onValueBlock: ((NetworkResponse) -> Void)?
    /// On Error block
    private var onErrorBlock: ((NetworkResponse) -> Void)?
    
    /// The actual code block to run.
    open func run() {
        fatalError("Subclass this method")
    }
    
    /// Primes the dispatch group to run the task on completion of constraints.
    ///
    /// - Parameter target: Dispatch Queue.
    internal func start(on target: DispatchQueue) {
        group.notify(queue: target) {
            self.run()
        }
    }
    
    /// Attaches the block to run on successful completion.
    ///
    /// - Parameter completion: completionBlock
    /// - Returns: Self
    @discardableResult public final func onValue(_ completion: @escaping ((NetworkResponse) -> Void)) -> Self {
        onValueBlock = completion
        return self
    }
    
    /// Attaches the block to run on errors faced.
    ///
    /// - Parameter completion: completionBlock
    /// - Returns: Self
    @discardableResult public final func onError(_ completion: @escaping ((NetworkResponse) -> ())) -> Self {
        onErrorBlock = completion
        return self
    }
    
    /// Executes the given completion block absed on the result.
    ///
    /// - Parameter result: Result
    public func finish(with result: Result) {
        switch result {
        case .success(let value):
            onValueBlock?(value)
        case .error(let error):
            onErrorBlock?(error)
        }
    }
}

