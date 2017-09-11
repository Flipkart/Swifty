//
//  SwiftyURLSessionDelegate.swift
//  Pods
//
//  Created by Siddharth Gupta on 24/03/17.
//
//

import Foundation

/// URL Session delegate.
class SwiftyURLSessionDelegate: NSObject {
    
    /// Shared singleton.
    static let shared = SwiftyURLSessionDelegate()
    
    /// Private init.
    override private init() {}
}

// MARK: - URLSessionTaskDelegate
extension SwiftyURLSessionDelegate: URLSessionTaskDelegate {
    @available(iOS 10.0, *)
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        SwiftyInspector.shared.add(NetworkResourceMetric(task: task, metrics: metrics))
    }
}
