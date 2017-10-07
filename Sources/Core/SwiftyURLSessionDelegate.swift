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

/// URL Session delegate.
class SwiftyURLSessionDelegate: NSObject {
    
    /// Shared singleton.
    static let shared = SwiftyURLSessionDelegate()
    
    /// Private init.
    override private init() {}
}

// MARK: - URLSessionTaskDelegate
extension SwiftyURLSessionDelegate: URLSessionTaskDelegate {
    #if os(iOS)
    @available(iOS 10.0, *)
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        SwiftyInspector.shared.add(NetworkResourceMetric(task: task, metrics: metrics))
    }
    #endif
}
