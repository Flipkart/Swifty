//
//  NetworkManager.swift
//  Swifty
//
//  Created by Siddharth Gupta on 30/04/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import Swifty

class NetworkManager: WebServiceNetworkInterface {
    
    static let shared = NetworkManager()
    
    let networkAdapter: Swifty
    
    private init(){
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.httpAdditionalHeaders = [
                                                        "CustomHeader": "SentWithEveryRequest"
                                                     ]
        networkAdapter = Swifty(configuration: sessionConfiguration,
                                constraints: [IPConstraint()],
                                requestInterceptors: [IPHeaderInterceptor()])
    }
    
    func loadResource(resource: NetworkResource, completion: @escaping (NetworkResponse) -> Void) {
        self.networkAdapter.add(resource, successBlock: { (networkResponse) in
            completion(networkResponse)
        }, failureBlock: { (networkResponse) in
            completion(networkResponse)
        })
    }
}
