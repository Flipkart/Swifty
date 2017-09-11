//
//  Constraint.swift
//  Pods
//
//  Created by Siddharth Gupta on 24/03/17.
//
//

import Foundation

/// Task State
///
/// - executing: currently being executed.
/// - notExecuting: Not being executed.
enum TaskState {
    case executing
    case notExecuting
}

/// Constraint: Defines constraints for the Network Requests.
open class Constraint {
    
    /// Public init.
    public init(){}
    
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
        synchronizer.sync {
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
    
    /// Determines whether the constraint is satisfied for the given Network Resource or not.
    ///
    /// - Parameter resource: NetworkResource
    /// - Returns: Bool
    open func isConstraintSatisfied(for resource: NetworkResource) -> Bool {
        fatalError("Must Be Subclassed")
    }
    
    /// Satisfies constrsaints for a given Network Resource.
    ///
    /// - Parameter resource: NetworkResource
    open func satisfyConstraint(for resource: NetworkResource) {
        fatalError("Must Be Subclassed")
    }
    
    /// Informs Swifty that the constraint has finished.
    /// If the constraint finishes without error, then the dependent tasks begin executing.
    /// If the constraint finishes with error, then the dependent task also fails with the corresponding error.
    /// - Parameter error: NSError?
    public func finish(with error: Error?) {
        synchronizer.sync {
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
