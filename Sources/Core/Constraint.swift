//
//
// Swifty (https://github.com/Flipkart/Swifty)
//
// Copyright 2017 Flipkart Internet Pvt. Ltd.
// Apache License
// Version 2.0, January 2004
//
// See https://github.com/Flipkart/Swifty/blob/master/LICENSE for the full license
//

import Foundation

/// Task State
/// Tracks the current state of Constraint execution
///
enum TaskState {
    /// - executing: Currently being executed / satisfied
    case executing
    /// - notExecuting: Not being executed / satisfied
    case notExecuting
}

/// Constraint: Constraints are tasks which can hold network requests from starting until they are satisfied.
open class Constraint {
    
    /// Public initializer
    @objc public init(){}
    
    /// Synchronizer - makes sure that constraint evaluation is thread-safe.
    let synchronizer = DispatchQueue(label: "swifty.constraintSyncronizer")
    
    /// Task state whether the task is being executed or not.
    internal var state: TaskState = .notExecuting
    
    /// An array of Swifty Network Task.
    internal var tasks = [SwiftyNetworkTask]()
    
    /// Evaluates what a constraint needs to do for a given resource.
    ///
    /// - Parameters:
    ///   - task: SwiftyNetworkTask
    ///   - target: DispatchQueue
    func satisfy(for task: SwiftyNetworkTask, on target: DispatchQueue) {
        synchronizer.async {
            if(self.isConstraintSatisfied(for: task.resource)) {
                task.group.leave()
            } else {
                switch(self.state){
                case .executing:
                    self.tasks.append(task)
                case .notExecuting:
                    self.tasks.append(task)
                    self.state = .executing
                    target.async {
                        self.satisfyConstraint(for: task.resource)
                    }
                }
            }
        }
    }
    
    /**
     This method is called on your constraint for every resource (with `canHaveConstraints = true`) that passes through Swifty.
     
     This is where you decide if you need to perform some action for the given resource to satisfy your constraint. Based on the decision, this method needs to return ```true``` or ```false```:
    - If you return ```true```, then the given resource will not wait for this Constraint.
    - In you return ```false```, then the given resource will start waiting for this Constraint, and Swifty will asynchronously call your ```satisfyConstraint``` method.
    
     > This method is called synchronously on a background thread.
     
     > This method is thread-safe, so you don't need to worry about multiple threads calling this method at the same time. Swifty internally locks access to this method to one resource at a time.

     - Parameter resource: NetworkResource
     - Returns: Bool
    */
    open func isConstraintSatisfied(for resource: NetworkResource) -> Bool {
        fatalError("Must Be Subclassed")
    }
    
    /**
     This method is called asynchronously when the `isConstraintSatisfied` method returns false.
     
     This is where the actual operation can be performed. The operation can be any task, not just a network request.
     
     > This method is always called on a background thread. Use `DispatchQueue.main.async` if you want to do something on the main thread.
     
     **When done, make sure the `finish` method is called to let Swifty continue the tasks that were waiting on this Constraint.**
     
     - Parameter resource: NetworkResource
     */
    open func satisfyConstraint(for resource: NetworkResource) {
        fatalError("Must Be Subclassed")
    }
    
    /** Informs Swifty that the constraint has finished.
     - If the constraint finishes `without` error, then the tasks waiting on this Constraint begin executing (subject to satisfaction of the task's other constraints).
     - If the constraint finishes `with` error, then the tasks waiting on this Constraint also fail with the this error.
    
     
     - Parameter error: NSError?
     */
    @objc public func finish(with error: Error?) {
        synchronizer.async {
            self.state = .notExecuting
            for task in self.tasks {
                if let error = error {
                    task.resource.creationError = error as NSError
                }
                task.group.leave()
            }
            self.tasks.removeAll()
        }
    }
}
